<?php
/**
 * PHP REST API for Flutter-OPAD
 * Migrated from Node.js due to hosting restrictions.
 */

// 1. CORS Headers
$origin = isset($_SERVER['HTTP_ORIGIN']) ? $_SERVER['HTTP_ORIGIN'] : '*';
// Allow localhost, 127.0.0.1 and the production domain explicitly to support credentials
if (preg_match('/^https?:\/\/(localhost|127\.0\.0\.1|opad\.com\.ua|www\.opad\.com\.ua)(:[0-9]+)?$/', $origin)) {
    header("Access-Control-Allow-Origin: $origin");
} else {
    // Fallback for others (note: Credentials won't work with *)
    header("Access-Control-Allow-Origin: *");
}
header("Access-Control-Allow-Credentials: true");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, Accept, Origin");
header("Access-Control-Max-Age: 3600");
header("Content-Type: application/json; charset=UTF-8");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// 1.5. Request Logging (Temporary for debugging)
$log_msg = date('[Y-m-d H:i:s] ') . $_SERVER['REQUEST_METHOD'] . ' ' . $_SERVER['REQUEST_URI'];
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $body = file_get_contents('php://input');
    $log_msg .= ' BODY: ' . $body;
}
@file_put_contents(__DIR__ . '/requests.log', $log_msg . PHP_EOL, FILE_APPEND);

// 2. Database Configuration (same as .env)
$host = 's19.thehost.com.ua';
$user = 'opad2016';
$pass = 'opad2016';
$db   = 'opad';

$mysqli = new mysqli($host, $user, $pass, $db);

if ($mysqli->connect_error) {
    http_response_code(500);
    echo json_encode(["error" => "Connection failed: " . $mysqli->connect_error]);
    exit();
}
$mysqli->set_charset("utf8mb4");

// 3. Helper Functions
function get_json_body() {
    return json_decode(file_get_contents('php://input'), true);
}

function md5Hash($input) {
    $secret = 'fsdfsd6287gf'; // Same as Node.js / WordPress
    return md5($secret . $input);
}

// 4. Routing
$method = $_SERVER['REQUEST_METHOD'];
$route = isset($_GET['route']) ? $_GET['route'] : '';

// Fallback to REQUEST_URI for local PHP server compatibility
if (empty($route)) {
    $route = explode('?', $_SERVER['REQUEST_URI'])[0];
    // Remove leading slash if it exists
    $route = ltrim($route, '/');
}

// Remove leading/trailing slashes and strip 'api/' or 'backend/' prefix
$route = trim($route, '/');
if (strpos($route, 'api/') === 0) {
    $route = substr($route, 4);
}
if (strpos($route, 'backend/') === 0) {
    $route = substr($route, 8);
}
$route = trim($route, '/');

switch (true) {
    // Health Check
    case ($route === 'health' || $route === 'api/health'):
        echo json_encode(["status" => "ok"]);
        break;

    // Debug Logs (Temporary)
    case ($route === 'debug/logs' || $route === 'api/debug/logs'):
        $logFile = __DIR__ . '/requests.log';
        if (file_exists($logFile)) {
            echo json_encode(["logs" => explode(PHP_EOL, file_get_contents($logFile))]);
        } else {
            echo json_encode(["error" => "Log file not found at $logFile"]);
        }
        break;

    // Debug Errors (Temporary)
    case ($route === 'debug/errors'):
        if (file_exists('api_errors.log')) {
            echo json_encode(["errors" => explode(PHP_EOL, file_get_contents('api_errors.log'))]);
        } else {
            echo json_encode(["error" => "No errors found"]);
        }
        break;

    // Get User Account by Email
    case ($route === 'users/account'):
        $email = isset($_GET['email']) ? $_GET['email'] : null;
        if (!$email) {
            http_response_code(400);
            echo json_encode(["error" => "Email is required"]);
            break;
        }
        $stmt = $mysqli->prepare("SELECT id, Email, Password, user_id FROM Users WHERE Email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();
        $user_data = $result->fetch_assoc();
        if (!$user_data) {
            http_response_code(404);
            echo json_encode(["error" => "User not found"]);
        } else {
            echo json_encode($user_data);
        }
        break;

    // Get User Stats
    case ($route === 'users/stats'):
        $param = isset($_GET['emailOrId']) ? $_GET['emailOrId'] : null;
        if (!$param) {
            http_response_code(400);
            echo json_encode(["error" => "Email or ID is required"]);
            break;
        }
        // Try email first
        $stmt = $mysqli->prepare("SELECT * FROM Stats WHERE Email = ?");
        $stmt->bind_param("s", $param);
        $stmt->execute();
        $result = $stmt->get_result();
        $stats = $result->fetch_assoc();
        
        // If not found, try by ID
        if (!$stats) {
            $stmt = $mysqli->prepare("SELECT * FROM Stats WHERE Id = ?");
            $stmt->bind_param("s", $param);
            $stmt->execute();
            $result = $stmt->get_result();
            $stats = $result->fetch_assoc();
        }

        if (!$stats) {
            http_response_code(404);
            echo json_encode(["error" => "Stats not found"]);
        } else {
            // Convert numbers to strings to match Node.js expected format
            $stats['Id'] = (string)$stats['Id'];
            $stats['Член-профсоюза'] = (string)$stats['Член-профсоюза'];
            echo json_encode($stats);
        }
        break;

    // Authentication
    case ($route === 'auth/login' && $method === 'POST'):
        $body = get_json_body();
        $email = isset($body['email']) ? $body['email'] : null;
        $password = isset($body['password']) ? $body['password'] : null;
        
        if (!$email || !$password) {
            http_response_code(400);
            echo json_encode(["error" => "Email and password are required"]);
            break;
        }

        // Check Users table
        $stmt = $mysqli->prepare("SELECT 1 FROM Users WHERE Email = ? AND Password = ?");
        $stmt->bind_param("ss", $email, $password);
        $stmt->execute();
        if ($stmt->get_result()->num_rows > 0) {
            echo json_encode(["success" => true]);
            break;
        }

        // Check Stats table
        $stmt = $mysqli->prepare("SELECT 1 FROM Stats WHERE Email = ? AND Password = ?");
        $stmt->bind_param("ss", $email, $password);
        $stmt->execute();
        if ($stmt->get_result()->num_rows > 0) {
            echo json_encode(["success" => true]);
        } else {
            echo json_encode(["success" => false]);
        }
        break;

    // Get All Users (Stats)
    case ($route === 'users/all'):
        $result = $mysqli->query("SELECT * FROM Stats ORDER BY ФИО");
        $users = [];
        while ($row = $result->fetch_assoc()) {
            $row['Id'] = (string)$row['Id'];
            $row['Член-профсоюза'] = (string)$row['Член-профсоюза'];
            $users[] = $row;
        }
        echo json_encode($users);
        break;

    // Get Union Members
    case ($route === 'users/union-members'):
        $result = $mysqli->query("SELECT * FROM Stats WHERE `Член-профсоюза` = 1 ORDER BY ФИО");
        $users = [];
        while ($row = $result->fetch_assoc()) {
            $row['Id'] = (string)$row['Id'];
            $row['Член-профсоюза'] = (string)$row['Член-профсоюза'];
            $users[] = $row;
        }
        echo json_encode($users);
        break;

    // Update Password
    case ($route === 'users/update-password' && $method === 'POST'):
        $body = get_json_body();
        $email = isset($body['email']) ? $body['email'] : null;
        $password = isset($body['password']) ? $body['password'] : null;

        if (!$email || !$password) {
            http_response_code(400);
            echo json_encode(["error" => "Email and password are required"]);
            break;
        }

        $mysqli->begin_transaction();
        try {
            // Update Users table
            $stmt1 = $mysqli->prepare("UPDATE Users SET Password = ? WHERE Email = ?");
            $stmt1->bind_param("ss", $password, $email);
            $stmt1->execute();
            $affected1 = $stmt1->affected_rows;

            // Update Stats table
            $stmt2 = $mysqli->prepare("UPDATE Stats SET Password = ? WHERE Email = ?");
            $stmt2->bind_param("ss", $password, $email);
            $stmt2->execute();
            $affected2 = $stmt2->affected_rows;

            $mysqli->commit();

            if ($affected1 > 0 || $affected2 > 0) {
                echo json_encode(["success" => true]);
            } else {
                echo json_encode(["success" => false, "message" => "User not found or password unchanged"]);
            }
        } catch (Exception $e) {
            $mysqli->rollback();
            http_response_code(500);
            echo json_encode(["error" => $e->getMessage()]);
        }
        break;

    // Database Statistics
    case ($route === 'stats/database'):
        // Total users
        $total_res = $mysqli->query("SELECT COUNT(*) as count FROM Stats");
        $total_count = $total_res->fetch_assoc()['count'];

        // Union members
        $union_res = $mysqli->query("SELECT COUNT(*) as count FROM Stats WHERE `Член-профсоюза` = 1");
        $union_count = $union_res->fetch_assoc()['count'];

        // Total balance
        $balance_res = $mysqli->query("SELECT SUM(`Общая сумма`) as total FROM Stats");
        $total_balance = $balance_res->fetch_assoc()['total'] ?: 0;

        echo json_encode([
            "total_users" => (int)$total_count,
            "union_members" => (int)$union_count,
            "total_balance" => (float)$total_balance,
            "non_union_members" => (int)($total_count - $union_count)
        ]);
        break;

    // Articles Stub
    case ($route === 'articles'):
        echo json_encode([]);
        break;

    case (preg_match('/^articles\/(\d+)$/', $route, $matches)):
        http_response_code(404);
        echo json_encode(["error" => "Article not found"]);
        break;

    default:
        http_response_code(404);
        echo json_encode(["error" => "Endpoint not found: " . $route]);
        break;
}

$mysqli->close();
