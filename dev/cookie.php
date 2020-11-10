
<!DOCTYPE html>
<html>
<body>

<h1>My first PHP page</h1>

<?php
foreach ($_COOKIE as $key=>$val)
{
     echo $key.' is '.$val."<br>\n";
}
?>

</body>
</html> 
