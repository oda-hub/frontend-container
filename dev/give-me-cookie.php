
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

<nav class="navbar navbar-default navbar-static-top navbar-inverse">
<div class="container">
<ul class="nav navbar-nav">
<li class="dropdown">
 <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-info-sign"></span> Report issue <span class="caret"></span></a>
 <ul class="dropdown-menu" role="menu">
    <li><a class="nav-link active" href="https://redmine.isdc.unige.ch/projects/cdci/issues/new?issue[fixed_version_id]=273">CDCI ODA core</a></li>
    <li><a class="nav-link active" href="https://redmine.isdc.unige.ch/projects/integral-web-analysis/issues/new?issue[fixed_version_id]=273">INTEGRAL</a></li>
    <li><a class="nav-link active" href="https://redmine.isdc.unige.ch/projects/polar-data-analysis/issues/new?issue[fixed_version_id]=273">POLAR</a></li>
 </ul>
</li>


<li>
<a class="nav-link" href="https://gitlab.astro.unige.ch/cdci/cdci-oda-stack/merge_requests/new?utf8=%E2%9C%93&merge_request%5Bsource_project_id%5D=554&merge_request%5Bsource_branch%5D=staging-1.2&merge_request%5Btarget_project_id%5D=554&merge_request%5Btarget_branch%5D=production-1.2">Merge staging-1.2 on production-1.2</a>
<ul class="dropdown-menu" role="menu">
<li>
<a class="nav-link" href="/astrooda/astrooda">ODA</a>
</li>
<li class="divider"></li>
</ul>
</li>
</ul>
</div>
</nav>

<div class="container">

<div class="row">
</div>

<div class="row">

<div class="col-sm-1"></div>
<div class="col-sm-16">
<?php

$c = $_COOKIE['_oauth2_proxy'];
$user = json_decode(base64_decode(preg_split('/\|/', $c)[0]))->User;

echo 'Dear <i>' . $user . '</i> <br>';
echo 'your temporary token is (between double quotes, skipping the quotes) "<b>' . $c . '</b>"';
echo '<br> Please refer to <a href="https://github.com/cdcihub/oda_api_benchmark/"> CDCI ODA BenchMark Repository</a> for examples';

?>


</div>
<div class="col-sm-1"></div>
</div>
</div>

</html>

</body>
