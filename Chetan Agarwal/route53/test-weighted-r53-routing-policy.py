#!/usr/bin/env python3

import subprocess
import time
import json
import statistics
from collections import defaultdict, Counter
import argparse
import sys

def run_dns_query(domain):
    """Perform DNS query and return the IP address"""
    try:
        result = subprocess.run(['dig', '+short', domain, 'A'], 
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0 and result.stdout.strip():
            # Return first IP if multiple are returned
            return result.stdout.strip().split('\n')[0]
        return None
    except subprocess.TimeoutExpired:
        return None
    except Exception as e:
        print(f"Error running dig: {e}")
        return None

def analyze_distribution(results, expected_weights=None):
    """Analyze the distribution of DNS responses"""
    counter = Counter(results)
    total = len(results)
    
    print(f"\n=== Distribution Analysis ===")
    print(f"Total queries: {total}")
    print(f"Unique IPs: {len(counter)}")
    print(f"Success rate: {(total - counter.get(None, 0)) / total * 100:.2f}%")
    
    print(f"\nIP Address Distribution:")
    print("-" * 50)
    
    for ip, count in counter.most_common():
        if ip is not None:
            percentage = (count / total) * 100
            print(f"{ip:<15} {count:>6} queries ({percentage:>6.2f}%)")
    
    if None in counter:
        failed_count = counter[None]
        percentage = (failed_count / total) * 100
        print(f"{'FAILED':<15} {failed_count:>6} queries ({percentage:>6.2f}%)")
    
    # Statistical analysis
    successful_results = [ip for ip in results if ip is not None]
    if len(set(successful_results)) > 1:
        print(f"\n=== Statistical Analysis ===")
        
        # Calculate chi-square test if expected weights are provided
        if expected_weights:
            print("Expected vs Actual Distribution:")
            print("-" * 40)
            for ip, expected_weight in expected_weights.items():
                actual_count = counter.get(ip, 0)
                expected_percentage = expected_weight
                actual_percentage = (actual_count / total) * 100
                difference = actual_percentage - expected_percentage
                print(f"{ip:<15} Expected: {expected_percentage:>6.2f}% | Actual: {actual_percentage:>6.2f}% | Diff: {difference:>+6.2f}%")

def time_series_analysis(results, bucket_count=10):
    """Analyze distribution over time buckets"""
    bucket_size = len(results) // bucket_count
    
    print(f"\n=== Time Series Analysis ({bucket_count} buckets) ===")
    print("-" * 60)
    
    for i in range(bucket_count):
        start_idx = i * bucket_size
        end_idx = start_idx + bucket_size if i < bucket_count - 1 else len(results)
        bucket_results = results[start_idx:end_idx]
        
        counter = Counter(bucket_results)
        print(f"Bucket {i+1:2d} (queries {start_idx+1:4d}-{end_idx:4d}):")
        
        for ip, count in counter.most_common():
            if ip is not None:
                percentage = (count / len(bucket_results)) * 100
                print(f"  {ip:<15} {count:>3} ({percentage:>5.1f}%)")

def main():
    parser = argparse.ArgumentParser(description='Test Route 53 weighted routing distribution')
    parser.add_argument('domain', help='Domain name to test')
    parser.add_argument('-n', '--queries', type=int, default=1000, help='Number of queries to perform')
    parser.add_argument('-i', '--interval', type=float, default=0.1, help='Sleep interval between queries')
    parser.add_argument('-w', '--weights', help='Expected weights as JSON (e.g., \'{"1.2.3.4": 70, "5.6.7.8": 30}\')')
    parser.add_argument('-o', '--output', help='Output file for raw results')
    
    args = parser.parse_args()
    
    # Parse expected weights if provided
    expected_weights = None
    if args.weights:
        try:
            expected_weights = json.loads(args.weights)
        except json.JSONDecodeError:
            print("Error: Invalid JSON format for weights")
            sys.exit(1)
    
    print(f"Testing weighted routing for: {args.domain}")
    print(f"Number of queries: {args.queries}")
    print(f"Interval between queries: {args.interval}s")
    print("=" * 50)
    
    results = []
    
    # Perform DNS queries
    for i in range(args.queries):
        ip = run_dns_query(args.domain)
        results.append(ip)
        
        # Progress indicator
        if (i + 1) % 100 == 0 or i == args.queries - 1:
            print(f"\rProgress: {i+1}/{args.queries} queries completed", end='', flush=True)
        
        time.sleep(args.interval)
    
    print()  # New line after progress indicator
    
    # Save raw results if output file specified
    if args.output:
        with open(args.output, 'w') as f:
            f.write("Query_Number,IP_Address\n")
            for i, ip in enumerate(results, 1):
                f.write(f"{i},{ip or 'NO_RESPONSE'}\n")
        print(f"Raw results saved to: {args.output}")
    
    # Analyze results
    analyze_distribution(results, expected_weights)
    time_series_analysis(results)
    
    print(f"\n=== Route 53 Verification Commands ===")
    print("To verify your weighted routing configuration:")
    print(f"aws route53 list-hosted-zones --query 'HostedZones[?Name==`{args.domain}.`].Id' --output text")
    print("aws route53 list-resource-record-sets --hosted-zone-id <ZONE_ID> --query 'ResourceRecordSets[?Type==`A`]'")

if __name__ == "__main__":
    main()
