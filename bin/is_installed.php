<?php
    // include config/local.php, and get the $parameters array
    $localConfigFile = __DIR__ . '/../config/local.php';
    
    // if the file does not exist, exit
    if (!file_exists($localConfigFile)) {
        exit(1);
    }

    require $localConfigFile;

    // if db_driver and site_url are present then it is assumed all the steps of the installation have been
    // performed; manually deleting these values or deleting the config file will be required to re-enter
    // installation.
    if (empty($parameters['db_driver']) || empty($parameters['site_url'])) {
        exit(1);
    }
?>