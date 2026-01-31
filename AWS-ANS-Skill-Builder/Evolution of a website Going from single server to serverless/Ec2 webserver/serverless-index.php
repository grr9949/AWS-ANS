sudo systemctl restart httpd[root@ip-10-0-1-133 html]# cat serverless-index.php
<!DOCTYPE html>
<html>
<head>
    <link
      href="https://fonts.googleapis.com/css2?family=Urbanist:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap"
      rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
</head>
<body>
    <!-- Announcement -->
    <div class="announcement">
        <p>Save 10%! With Promo Code ANYCO</p>
    </div>
    <!-- Header -->
    <div class="header">
        <h1>ANYCO.</h1>
    </div>
    <!-- Main Body -->
    <div class="row">
        <div class="column">
        <img src="./images/main_icecream.jpg" style="width:100%">
        </div>
        <div class="column">
            <div class="cta">
                <p1>DON'T COMPROMISE ON TASTE! TRY OUR BOLD, CLASSIC FLAVORS TODAY.</p1>
            </div>
            <div class="menu">
                <?php

                    // Autoloader required - using Composer
                    require 'vendor/autoload.php';

                    use Aws\DynamoDb\DynamoDbClient;
                    use Aws\Credentials\Credentials;

                    try {
                        // Create credentials object explicitly for AWS SDK v3
                        $credentials = new Credentials(
                            getenv('AWS_ACCESS_KEY_ID'),
                            getenv('AWS_SECRET_ACCESS_KEY')
                        );

                        $client = new DynamoDbClient([
                            'version' => 'latest',
                            'region' => 'us-west-2',
                            'credentials' => $credentials
                        ]);

                        $result = $client->scan(['TableName' => 'Products']);

                        echo "<table class='db-table'>";
                        echo "<ul1>In Store Now:</ul1>";
                        echo "<tr><td>Flavor</td><td>Price</td></tr>";

                        foreach ($result['Items'] as $item) {
                            $flavor = isset($item['ProductFlavor']['S']) ? $item['ProductFlavor']['S'] : 'Unknown';
                            $price = isset($item['ProductPrice']['S']) ? $item['ProductPrice']['S'] : '0.00';
                            echo "<tr><td>{$flavor}</td><td>\${$price}</td></tr>";
                        }
                        echo "</table>";

                    } catch (Exception $e) {
                        echo "<table class='db-table'>";
                        echo "<tr><td colspan='2'>Error: " . $e->getMessage() . "</td></tr>";
                        echo "</table>";
                    }

                ?>
            </div>
        </div>
      </div>
    <!-- Footer -->
    <div class="footer">
        <div class="footer-container1">
            <p2>Contact Us.</p2><br>
            <p2>(555) 555-1212</p2><br>
            <p2>1234 AnyCompany Drive</p2><br>
            <p2>AnyTown, USA, 55555</p2>
        </div>
        <div class="footer-container2"">
            <a href="#" class="fa fa-facebook"></a>
            <a href="#" class="fa fa-twitter"></a>
            <a href="#" class="fa fa-instagram"></a>
            <a href="#" class="fa fa-pinterest"></a>
        </div>
    </div>

</body>
</html>