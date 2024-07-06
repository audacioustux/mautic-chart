<?php
    // include config/local.php, and get the $parameters array
    $localConfigFile = __DIR__ . '/../config/local.php';

    // flock a .lock file to prevent multiple instances of this script from running at the same time
    // atomic file locking
    $lockFile = $localConfigFile . '.lock';
    $lock = fopen($lockFile, 'w');
    if (!flock($lock, LOCK_EX | LOCK_NB)) {
        exit(1);
    }

    sleep(100);
    print_r($parameters);

    require $localConfigFile;

    // get all the environment variables starting with MAUTIC_
    // take the part after MAUTIC_ and convert it to lowercase as the key
    // then, set key => value in the $parameters array
    $prefix = 'MAUTIC_';
    $prefixLength = strlen($prefix);
    foreach (getenv() as $key => $value) {
        if (strpos($key, $prefix) === 0) {
            $key = strtolower(substr($key, $prefixLength));
            $parameters[$key] = json_decode($value) ?: $value;
        }
    }

    // sync the $parameters array to the local.php file
    $rendered = '<?php' . PHP_EOL . '$parameters = ' . var_export($parameters, true) . ';' . PHP_EOL;
    file_put_contents($localConfigFile, $rendered);

    // release the lock
    flock($lock, LOCK_UN);
    fclose($lock);
    unlink($lockFile);
?>