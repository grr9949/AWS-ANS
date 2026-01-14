#!/bin/bash

################################################################################
# Autobots Transformers EC2 Web Deployment Script
# This script automatically detects Amazon Linux version, installs httpd,
# and deploys a Transformers-themed webpage with EC2 metadata
################################################################################

set -e

echo "=========================================="
echo "🤖 AUTOBOTS, ROLL OUT! 🤖"
echo "=========================================="

# Detect Linux distribution and version
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
        echo "✓ Detected OS: $NAME $VERSION"
    else
        echo "✗ Cannot detect OS version"
        exit 1
    fi
}

# Install httpd based on Amazon Linux version
install_httpd() {
    echo ""
    echo "Installing Apache HTTP Server..."
    
    if [[ "$OS" == "amzn" ]]; then
        if [[ "$VER" == "2" ]] || [[ "$VER" == "2023" ]]; then
            echo "✓ Amazon Linux 2/2023 detected"
            sudo yum update -y
            sudo yum install -y httpd
        else
            echo "✓ Amazon Linux detected"
            sudo yum update -y
            sudo yum install -y httpd
        fi
    else
        echo "✓ Installing httpd..."
        sudo yum install -y httpd || sudo dnf install -y httpd
    fi
    
    echo "✓ Apache installed successfully"
}



# Fetch EC2 metadata
fetch_metadata() {
    echo ""
    echo "Gathering Autobot intelligence (EC2 Metadata)..."
    
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null || echo "")
    
    if [ -z "$TOKEN" ]; then
        # Fallback to IMDSv1
        INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "unavailable")
        PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "unavailable")
        PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null || echo "unavailable")
        AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null || echo "unavailable")
        REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null || echo "unavailable")
        INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type 2>/dev/null || echo "unavailable")
        AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-id 2>/dev/null || echo "unavailable")
        HOSTNAME=$(curl -s http://169.254.169.254/latest/meta-data/hostname 2>/dev/null || echo "unavailable")
    else
        # Use IMDSv2
        INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "unavailable")
        PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "unavailable")
        PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null || echo "unavailable")
        AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone 2>/dev/null || echo "unavailable")
        REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region 2>/dev/null || echo "unavailable")
        INSTANCE_TYPE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-type 2>/dev/null || echo "unavailable")
        AMI_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/ami-id 2>/dev/null || echo "unavailable")
        HOSTNAME=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/hostname 2>/dev/null || echo "unavailable")
    fi
    
    echo "✓ Metadata collected"
}

# Create the Autobots webpage
create_webpage() {
    echo ""
    echo "Deploying Autobots Command Center..."
    
    sudo tee /var/www/html/index.html > /dev/null <<'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Autobots Command Center - AWS EC2</title>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Rajdhani:wght@300;400;600;700&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Rajdhani', sans-serif;
            background: #000;
            color: #fff;
            overflow-x: hidden;
            min-height: 100vh;
            position: relative;
        }

        /* Cinematic background with depth */
        .bg-layer {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
        }

        .bg-layer::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: radial-gradient(ellipse at center, rgba(0, 100, 255, 0.15) 0%, transparent 70%),
                        radial-gradient(ellipse at 20% 80%, rgba(255, 50, 0, 0.1) 0%, transparent 50%);
            animation: ambientGlow 8s ease-in-out infinite alternate;
        }

        @keyframes ambientGlow {
            0% { opacity: 0.3; }
            100% { opacity: 0.6; }
        }

        /* Hexagonal tech pattern */
        .hex-pattern {
            position: fixed;
            width: 100%;
            height: 100%;
            background-image: 
                repeating-linear-gradient(90deg, rgba(0, 150, 255, 0.03) 0px, transparent 1px, transparent 40px, rgba(0, 150, 255, 0.03) 41px),
                repeating-linear-gradient(0deg, rgba(0, 150, 255, 0.03) 0px, transparent 1px, transparent 40px, rgba(0, 150, 255, 0.03) 41px);
            z-index: -1;
            opacity: 0.4;
        }

        .container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 40px 20px;
            position: relative;
        }

        /* Cinematic header */
        header {
            text-align: center;
            padding: 60px 20px 40px;
            position: relative;
            overflow: hidden;
        }

        .title-container {
            position: relative;
            display: inline-block;
        }

        .logo {
            font-size: 6em;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 20px;
            color: #fff;
            text-shadow: 
                0 0 10px rgba(0, 150, 255, 0.8),
                0 0 20px rgba(0, 150, 255, 0.6),
                0 0 40px rgba(0, 150, 255, 0.4),
                0 5px 10px rgba(0, 0, 0, 0.8);
            position: relative;
            animation: titleGlow 3s ease-in-out infinite;
        }

        @keyframes titleGlow {
            0%, 100% { 
                text-shadow: 
                    0 0 10px rgba(0, 150, 255, 0.8),
                    0 0 20px rgba(0, 150, 255, 0.6),
                    0 0 40px rgba(0, 150, 255, 0.4),
                    0 5px 10px rgba(0, 0, 0, 0.8);
            }
            50% { 
                text-shadow: 
                    0 0 20px rgba(0, 150, 255, 1),
                    0 0 40px rgba(0, 150, 255, 0.8),
                    0 0 60px rgba(0, 150, 255, 0.6),
                    0 5px 10px rgba(0, 0, 0, 0.8);
            }
        }

        .subtitle {
            font-size: 1.4em;
            margin-top: 20px;
            color: #00bfff;
            text-transform: uppercase;
            letter-spacing: 8px;
            font-weight: 300;
            opacity: 0.9;
        }

        /* Autobot grid with cinematic cards */
        .autobots-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 40px;
            margin-top: 60px;
            padding: 20px;
            perspective: 1000px;
        }

        .autobot-card {
            background: linear-gradient(135deg, rgba(10, 25, 47, 0.95) 0%, rgba(5, 10, 20, 0.98) 100%);
            border: 1px solid rgba(0, 150, 255, 0.3);
            border-radius: 8px;
            padding: 0;
            position: relative;
            overflow: hidden;
            cursor: pointer;
            transition: all 0.6s cubic-bezier(0.23, 1, 0.32, 1);
            box-shadow: 
                0 10px 40px rgba(0, 0, 0, 0.6),
                inset 0 1px 0 rgba(255, 255, 255, 0.1);
            transform-style: preserve-3d;
        }

        /* Mechanical transformation effect */
        .autobot-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, 
                transparent 0%, 
                rgba(0, 150, 255, 0.3) 50%, 
                transparent 100%);
            transition: left 0.8s;
            z-index: 1;
        }

        .autobot-card:hover::before {
            left: 100%;
        }

        .autobot-card::after {
            content: '';
            position: absolute;
            top: -2px;
            left: -2px;
            right: -2px;
            bottom: -2px;
            background: linear-gradient(45deg, 
                transparent 0%, 
                rgba(0, 150, 255, 0.4) 50%, 
                transparent 100%);
            border-radius: 8px;
            opacity: 0;
            transition: opacity 0.6s;
            z-index: -1;
        }

        .autobot-card:hover::after {
            opacity: 1;
        }

        .autobot-card:hover {
            transform: translateY(-10px) scale(1.02);
            border-color: rgba(0, 150, 255, 0.8);
            box-shadow: 
                0 20px 60px rgba(0, 100, 255, 0.4),
                0 0 40px rgba(0, 150, 255, 0.3),
                inset 0 1px 0 rgba(255, 255, 255, 0.2);
        }

        /* Mechanical parts animation */
        .card-header {
            position: relative;
            padding: 30px;
            border-bottom: 1px solid rgba(0, 150, 255, 0.2);
            background: linear-gradient(180deg, rgba(0, 100, 255, 0.05) 0%, transparent 100%);
            transition: all 0.6s;
        }

        .autobot-card:hover .card-header {
            background: linear-gradient(180deg, rgba(0, 100, 255, 0.15) 0%, transparent 100%);
        }

        .autobot-icon {
            width: 150px;
            height: 150px;
            font-size: 150px;
            text-align: center;
            margin-bottom: 15px;
            filter: drop-shadow(0 4px 8px rgba(0, 150, 255, 0.4));
            transition: all 0.6s cubic-bezier(0.68, -0.55, 0.265, 1.55);
            display: block;
            margin-left: auto;
            margin-right: auto;
        }

        .autobot-card:hover .autobot-icon {
            transform: scale(1.1) translateZ(20px);
            filter: drop-shadow(0 8px 16px rgba(0, 150, 255, 0.8));
        }

        /* Complex transformation sequence on hover */
        @keyframes mechanicalTransform {
            0% { 
                transform: scale(1) rotate(0deg);
                filter: brightness(1);
            }
            20% { 
                transform: scale(0.9) rotate(-5deg);
                filter: brightness(1.2);
            }
            40% { 
                transform: scale(1.05) rotate(5deg) translateY(-5px);
                filter: brightness(1.4);
            }
            60% { 
                transform: scale(0.95) rotate(-3deg) translateY(-3px);
                filter: brightness(1.3);
            }
            80% { 
                transform: scale(1.02) rotate(2deg) translateY(-7px);
                filter: brightness(1.5);
            }
            100% { 
                transform: scale(1.1) rotate(0deg) translateY(-10px);
                filter: brightness(1.6);
            }
        }

        .autobot-card:hover .autobot-icon {
            animation: mechanicalTransform 0.8s cubic-bezier(0.68, -0.55, 0.265, 1.55) forwards;
        }

        .autobot-name {
            font-size: 1.6em;
            font-weight: 700;
            text-align: center;
            color: #00bfff;
            text-transform: uppercase;
            letter-spacing: 3px;
            text-shadow: 0 2px 10px rgba(0, 150, 255, 0.6);
            transition: all 0.4s;
        }

        .autobot-card:hover .autobot-name {
            color: #fff;
            text-shadow: 0 2px 20px rgba(0, 150, 255, 1);
            letter-spacing: 5px;
        }

        .card-body {
            padding: 30px;
        }

        .autobot-label {
            font-size: 0.85em;
            color: rgba(255, 255, 255, 0.5);
            text-transform: uppercase;
            letter-spacing: 2px;
            margin-bottom: 10px;
            font-weight: 300;
        }

        .autobot-info {
            font-size: 1.3em;
            color: #00bfff;
            padding: 15px 20px;
            background: rgba(0, 100, 255, 0.05);
            border-left: 3px solid rgba(0, 150, 255, 0.6);
            font-family: 'Courier New', monospace;
            word-wrap: break-word;
            letter-spacing: 1px;
            transition: all 0.4s;
            position: relative;
            overflow: hidden;
        }

        .autobot-info::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 3px;
            background: linear-gradient(180deg, 
                rgba(0, 150, 255, 1) 0%, 
                rgba(0, 200, 255, 1) 50%, 
                rgba(0, 150, 255, 1) 100%);
            box-shadow: 0 0 10px rgba(0, 150, 255, 0.8);
            animation: energyFlow 2s linear infinite;
        }

        @keyframes energyFlow {
            0% { transform: translateY(-100%); }
            100% { transform: translateY(100%); }
        }

        .autobot-card:hover .autobot-info {
            background: rgba(0, 100, 255, 0.1);
            border-left-color: rgba(0, 200, 255, 1);
            color: #fff;
            transform: translateX(5px);
        }

        /* Tech corners */
        .tech-corner {
            position: absolute;
            width: 30px;
            height: 30px;
            border: 2px solid rgba(0, 150, 255, 0.4);
            transition: all 0.6s;
        }

        .tech-corner.top-left {
            top: 10px;
            left: 10px;
            border-right: none;
            border-bottom: none;
        }

        .tech-corner.top-right {
            top: 10px;
            right: 10px;
            border-left: none;
            border-bottom: none;
        }

        .tech-corner.bottom-left {
            bottom: 10px;
            left: 10px;
            border-right: none;
            border-top: none;
        }

        .tech-corner.bottom-right {
            bottom: 10px;
            right: 10px;
            border-left: none;
            border-top: none;
        }

        .autobot-card:hover .tech-corner {
            border-color: rgba(0, 200, 255, 1);
            box-shadow: 0 0 10px rgba(0, 150, 255, 0.8);
        }

        /* Scanning line effect */
        .scan-line {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 2px;
            background: linear-gradient(90deg, 
                transparent 0%, 
                rgba(0, 200, 255, 0.8) 50%, 
                transparent 100%);
            box-shadow: 0 0 10px rgba(0, 150, 255, 0.8);
            animation: scanMove 3s linear infinite;
            opacity: 0;
        }

        .autobot-card:hover .scan-line {
            opacity: 1;
        }

        @keyframes scanMove {
            0% { transform: translateY(0); }
            100% { transform: translateY(400px); }
        }

        footer {
            text-align: center;
            padding: 60px 20px;
            margin-top: 80px;
            border-top: 1px solid rgba(0, 150, 255, 0.2);
            background: linear-gradient(180deg, transparent 0%, rgba(0, 50, 100, 0.2) 100%);
        }

        .footer-text {
            font-size: 1.4em;
            color: #00bfff;
            text-shadow: 0 2px 10px rgba(0, 150, 255, 0.6);
            letter-spacing: 3px;
            font-weight: 300;
            margin-bottom: 15px;
        }

        .footer-subtext {
            color: rgba(255, 255, 255, 0.5);
            font-size: 1em;
            letter-spacing: 2px;
            font-weight: 300;
        }

        /* Lens flare effect */
        .lens-flare {
            position: fixed;
            width: 600px;
            height: 600px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(0, 150, 255, 0.2) 0%, transparent 70%);
            pointer-events: none;
            mix-blend-mode: screen;
            animation: flareMove 20s ease-in-out infinite;
            z-index: 10;
        }

        @keyframes flareMove {
            0%, 100% { 
                top: -10%; 
                right: -10%; 
                opacity: 0.3;
            }
            50% { 
                top: 60%; 
                right: 70%; 
                opacity: 0.6;
            }
        }

        @media (max-width: 768px) {
            .logo { 
                font-size: 3em; 
                letter-spacing: 10px;
            }
            .subtitle { 
                font-size: 1em;
                letter-spacing: 4px;
            }
            .autobots-grid { 
                grid-template-columns: 1fr;
                gap: 30px;
            }
        }
    </style>
</head>
<body>
    <div class="bg-layer"></div>
    <div class="hex-pattern"></div>
    <div class="lens-flare"></div>
    
    <div class="container">
        <header>
            <div class="title-container">
                <div class="logo">AUTOBOTS</div>
            </div>
            <div class="subtitle">AWS EC2 COMMAND CENTER</div>
        </header>

        <div class="autobots-grid">
            <!-- Optimus Prime - Instance ID -->
            <div class="autobot-card">
                <div class="scan-line"></div>
                <div class="tech-corner top-left"></div>
                <div class="tech-corner top-right"></div>
                <div class="tech-corner bottom-left"></div>
                <div class="tech-corner bottom-right"></div>
                <div class="card-header">
                    <div class="autobot-icon">🚛</div>
                    <div class="autobot-name">Optimus Prime</div>
                </div>
                <div class="card-body">
                    <div class="autobot-label">Instance ID</div>
                    <div class="autobot-info">INSTANCE_ID_PLACEHOLDER</div>
                </div>
            </div>

            <!-- Bumblebee - Public IP -->
            <div class="autobot-card">
                <div class="scan-line"></div>
                <div class="tech-corner top-left"></div>
                <div class="tech-corner top-right"></div>
                <div class="tech-corner bottom-left"></div>
                <div class="tech-corner bottom-right"></div>
                <div class="card-header">
                    <div class="autobot-icon">🐝</div>
                    <div class="autobot-name">Bumblebee</div>
                </div>
                <div class="card-body">
                    <div class="autobot-label">Public IP Address</div>
                    <div class="autobot-info">PUBLIC_IP_PLACEHOLDER</div>
                </div>
            </div>

            <!-- Jazz - Private IP -->
            <div class="autobot-card">
                <div class="scan-line"></div>
                <div class="tech-corner top-left"></div>
                <div class="tech-corner top-right"></div>
                <div class="tech-corner bottom-left"></div>
                <div class="tech-corner bottom-right"></div>
                <div class="card-header">
                    <div class="autobot-icon">🏎️</div>
                    <div class="autobot-name">Jazz</div>
                </div>
                <div class="card-body">
                    <div class="autobot-label">Private IP Address</div>
                    <div class="autobot-info">PRIVATE_IP_PLACEHOLDER</div>
                </div>
            </div>

            <!-- Ironhide - Availability Zone -->
            <div class="autobot-card">
                <div class="scan-line"></div>
                <div class="tech-corner top-left"></div>
                <div class="tech-corner top-right"></div>
                <div class="tech-corner bottom-left"></div>
                <div class="tech-corner bottom-right"></div>
                <div class="card-header">
                    <div class="autobot-icon">🛡️</div>
                    <div class="autobot-name">Ironhide</div>
                </div>
                <div class="card-body">
                    <div class="autobot-label">Availability Zone</div>
                    <div class="autobot-info">AZ_PLACEHOLDER</div>
                </div>
            </div>

            <!-- Ratchet - Region -->
            <div class="autobot-card">
                <div class="scan-line"></div>
                <div class="tech-corner top-left"></div>
                <div class="tech-corner top-right"></div>
                <div class="tech-corner bottom-left"></div>
                <div class="tech-corner bottom-right"></div>
                <div class="card-header">
                    <div class="autobot-icon">🔧</div>
                    <div class="autobot-name">Ratchet</div>
                </div>
                <div class="card-body">
                    <div class="autobot-label">AWS Region</div>
                    <div class="autobot-info">REGION_PLACEHOLDER</div>
                </div>
            </div>

            <!-- Wheeljack - Instance Type -->
            <div class="autobot-card">
                <div class="scan-line"></div>
                <div class="tech-corner top-left"></div>
                <div class="tech-corner top-right"></div>
                <div class="tech-corner bottom-left"></div>
                <div class="tech-corner bottom-right"></div>
                <div class="card-body">
                    <div class="autobot-label">Instance Type</div>
                    <div class="autobot-info">INSTANCE_TYPE_PLACEHOLDER</div>
                </div>
            </div>

            <!-- Prowl - AMI ID -->
            <div class="autobot-card">
                <div class="scan-line"></div>
                <div class="tech-corner top-left"></div>
                <div class="tech-corner top-right"></div>
                <div class="tech-corner bottom-left"></div>
                <div class="tech-corner bottom-right"></div>
                <div class="card-header">
                    <div class="autobot-icon">🥷</div>
                    <div class="autobot-name">Prowl</div>
                </div>
                <div class="card-body">
                    <div class="autobot-label">AMI ID</div>
                    <div class="autobot-info">AMI_ID_PLACEHOLDER</div>
                </div>
            </div>

            <!-- Bluestreak - Hostname -->
            <div class="autobot-card">
                <div class="scan-line"></div>
                <div class="tech-corner top-left"></div>
                <div class="tech-corner top-right"></div>
                <div class="tech-corner bottom-left"></div>
                <div class="tech-corner bottom-right"></div>
                <div class="card-header">
                    <div class="autobot-icon">🔫</div>
                    <div class="autobot-name">Bluestreak</div>
                </div>
                <div class="card-body">
                    <div class="autobot-label">Hostname</div>
                    <div class="autobot-info">HOSTNAME_PLACEHOLDER</div>
                </div>
            </div>
        </div>

        <footer>
            <div class="footer-text">
                FREEDOM IS THE RIGHT OF ALL SENTIENT BEINGS
            </div>
            <div class="footer-subtext">
                AWS EC2 • AMAZON LINUX • DEPLOYED
            </div>
        </footer>
    </div>

    <script>
        // Cinematic parallax effect
        document.addEventListener('mousemove', (e) => {
            const cards = document.querySelectorAll('.autobot-card');
            const x = e.clientX / window.innerWidth;
            const y = e.clientY / window.innerHeight;
            
            cards.forEach((card, index) => {
                const speed = (index + 1) * 0.5;
                const xOffset = (x - 0.5) * speed;
                const yOffset = (y - 0.5) * speed;
                
                card.style.transform = `
                    translateX(${xOffset}px) 
                    translateY(${yOffset}px)
                    rotateY(${xOffset * 2}deg)
                    rotateX(${-yOffset * 2}deg)
                `;
            });
        });

        // Reset on mouse leave
        document.addEventListener('mouseleave', () => {
            const cards = document.querySelectorAll('.autobot-card');
            cards.forEach(card => {
                card.style.transform = '';
            });
        });

        // Mechanical sound effect simulation (visual)
        document.querySelectorAll('.autobot-card').forEach(card => {
            card.addEventListener('mouseenter', function() {
                // Create a ripple effect
                const ripple = document.createElement('div');
                ripple.style.position = 'absolute';
                ripple.style.width = '100%';
                ripple.style.height = '100%';
                ripple.style.top = '0';
                ripple.style.left = '0';
                ripple.style.background = 'radial-gradient(circle, rgba(0,150,255,0.4) 0%, transparent 70%)';
                ripple.style.pointerEvents = 'none';
                ripple.style.animation = 'rippleEffect 0.6s ease-out';
                this.appendChild(ripple);
                
                setTimeout(() => ripple.remove(), 600);
            });
        });

        // Add ripple animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes rippleEffect {
                0% { transform: scale(0); opacity: 1; }
                100% { transform: scale(1.5); opacity: 0; }
            }
        `;
        document.head.appendChild(style);
    </script>
</body>
</html>
HTMLEOF

    # Replace placeholders with actual metadata
    sudo sed -i "s/INSTANCE_ID_PLACEHOLDER/$INSTANCE_ID/g" /var/www/html/index.html
    sudo sed -i "s/PUBLIC_IP_PLACEHOLDER/$PUBLIC_IP/g" /var/www/html/index.html
    sudo sed -i "s/PRIVATE_IP_PLACEHOLDER/$PRIVATE_IP/g" /var/www/html/index.html
    sudo sed -i "s/AZ_PLACEHOLDER/$AZ/g" /var/www/html/index.html
    sudo sed -i "s/REGION_PLACEHOLDER/$REGION/g" /var/www/html/index.html
    sudo sed -i "s/INSTANCE_TYPE_PLACEHOLDER/$INSTANCE_TYPE/g" /var/www/html/index.html
    sudo sed -i "s/AMI_ID_PLACEHOLDER/$AMI_ID/g" /var/www/html/index.html
    sudo sed -i "s/HOSTNAME_PLACEHOLDER/$HOSTNAME/g" /var/www/html/index.html
    
    echo "✓ Autobots Command Center deployed"
}

# Start and enable httpd service
start_httpd() {
    echo ""
    echo "Activating Autobot defenses (Starting Apache)..."
    
    sudo systemctl start httpd
    sudo systemctl enable httpd
    
    echo "✓ Apache HTTP Server is running"
}

# Configure firewall if needed
configure_firewall() {
    echo ""
    echo "Opening communication channels..."
    
    if command -v firewall-cmd &> /dev/null; then
        sudo firewall-cmd --permanent --add-service=http
        sudo firewall-cmd --reload
        echo "✓ Firewall configured"
    else
        echo "✓ No firewall configuration needed"
    fi
}

# Main execution
main() {
    detect_os
    install_httpd
    fetch_metadata
    create_webpage
    start_httpd
    configure_firewall
    
    echo ""
    echo "=========================================="
    echo "✓ DEPLOYMENT COMPLETE!"
    echo "=========================================="
    echo ""
    echo "🤖 Autobots Command Center is ONLINE!"
    echo ""
    echo "Access your webpage at:"
    if [ "$PUBLIC_IP" != "unavailable" ]; then
        echo "  http://$PUBLIC_IP"
    else
        echo "  http://localhost (from instance)"
    fi
    echo ""
    echo "⚡ AUTOBOTS, TRANSFORM AND ROLL OUT! ⚡"
    echo ""
}

# Run the script
main