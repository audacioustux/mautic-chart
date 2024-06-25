<?php
// If the config file doesn't even exist, no point in checking further
$localConfigFile = __DIR__ . '/../config/local.php';
if (!file_exists($localConfigFile)) {
    exit(1);
}

$parameters = require $localConfigFile;

// if db_driver and site_url are present then it is assumed all the steps of the installation have been
// performed; manually deleting these values or deleting the config file will be required to re-enter
// installation.
if (empty($params['db_driver']) || empty($params['site_url'])) {
    exit(1);
}
?>