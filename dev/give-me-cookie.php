
<!DOCTYPE html>
<html>
<body>

<h1>Hello. This is a temporary page</h1>

<?php
foreach ($_COOKIE as $key=>$val)
{
     echo $key.' is '.$val."<br>\n";
}

echo "your token is (between double quotes, skipping the quotes) \"" . $_COOKIE['_oauth2_proxy'] . "\""

?>

</body>
</html> 
