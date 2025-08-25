<?php
/**
 * Health Check Endpoint for EspoCRM
 * Used by Dokploy/Docker for health monitoring
 */

// Simple health check - verify basic application functionality
header('Content-Type: application/json');

$response = [
    'status' => 'healthy',
    'timestamp' => date('c'),
    'checks' => []
];

$httpCode = 200;

try {
    // Check if config file exists
    $configPath = dirname(dirname(dirname(__DIR__))) . '/data/config.php';
    if (file_exists($configPath)) {
        $response['checks']['config'] = 'ok';
    } else {
        $response['checks']['config'] = 'missing';
        $response['status'] = 'unhealthy';
        $httpCode = 503;
    }

    // Check if we can connect to the application
    $appPath = dirname(dirname(dirname(__DIR__))) . '/application/Espo/Core/Application.php';
    if (file_exists($appPath)) {
        $response['checks']['application'] = 'ok';
    } else {
        $response['checks']['application'] = 'missing';
        $response['status'] = 'unhealthy';
        $httpCode = 503;
    }

    // Check if data directory is writable
    $dataPath = dirname(dirname(dirname(__DIR__))) . '/data';
    if (is_writable($dataPath)) {
        $response['checks']['data_writable'] = 'ok';
    } else {
        $response['checks']['data_writable'] = 'not_writable';
        $response['status'] = 'unhealthy';
        $httpCode = 503;
    }

    // Check PHP version
    if (version_compare(PHP_VERSION, '8.2.0', '>=')) {
        $response['checks']['php_version'] = PHP_VERSION;
    } else {
        $response['checks']['php_version'] = 'unsupported: ' . PHP_VERSION;
        $response['status'] = 'unhealthy';
        $httpCode = 503;
    }

    // Check required PHP extensions
    $requiredExtensions = ['pdo', 'pdo_mysql', 'json', 'openssl', 'mbstring', 'zip', 'gd', 'curl'];
    $missingExtensions = [];
    
    foreach ($requiredExtensions as $ext) {
        if (!extension_loaded($ext)) {
            $missingExtensions[] = $ext;
        }
    }
    
    if (empty($missingExtensions)) {
        $response['checks']['php_extensions'] = 'ok';
    } else {
        $response['checks']['php_extensions'] = 'missing: ' . implode(', ', $missingExtensions);
        $response['status'] = 'unhealthy';
        $httpCode = 503;
    }

} catch (Exception $e) {
    $response['status'] = 'unhealthy';
    $response['error'] = $e->getMessage();
    $httpCode = 503;
}

// Set appropriate HTTP status code
http_response_code($httpCode);

// Output JSON response
echo json_encode($response, JSON_PRETTY_PRINT);
exit;