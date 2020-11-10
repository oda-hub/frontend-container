
<html>
<head>

<style type="text/css">
.jumbotron {
background: #532f8c;
color: white;
       padding-bottom: 80px
}
.jumbotron .btn-primary {
background: #845ac7;
            border-color: #845ac7
}
.jumbotron .btn-primary:hover {
background: #7646c1
}
.jumbotron p {
color: #d9ccee;
       max-width: 75%;
margin: 1em auto 2em
}
.navbar+.jumbotron {
    margin-top: -20px
}
.jumbotron .lang-logo {
display: block;
background: #b01302;
            border-radius: 50%;
overflow: hidden;
width: 100px;
height: 100px;
margin: auto;
border: 2px solid white
}
.jumbotron .lang-logo img {
    max-width: 100%
}


</style>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.10.1/jquery.min.js"></script>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
</head>

<body>

<div class="container">

<div class="row">
</div>

<div class="row">

<div class="col-sm-1"></div>
<div class="col-sm-16">
<?php

decoded = base64_decode($_COOKIE['_oauth2_proxy']['User']);


echo 'Dear 'decoded['User'] . 'your token is (between double quotes, skipping the quotes) "' . $_COOKIE['_oauth2_proxy'] . '"';
echo '<br> Please refer to <a href="https://github.com/cdcihub/oda_api_benchmark/"> CDCI ODA BenchMark Repository</a> for examples;

?>


</div>
<div class="col-sm-1"></div>
</div>
</div>

</html>

</body>
