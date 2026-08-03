<%@ page contentType="text/html;charset=UTF-8"%>

<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Expense Details</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">

<link rel="stylesheet" href="../assets/css/style.css">

</head>

<body>

<div class="dashboard">

<jsp:include page="../components/sidebar.jsp"/>

<main class="main">

<nav class="topbar">

<h3>Expense Details</h3>

</nav>

<div class="content">

<div class="table-box">

<h4>Business Lunch</h4>

<hr>

<p><strong>Category :</strong> Food</p>

<p><strong>Amount :</strong> ₹650</p>

<p><strong>Date :</strong> 03 Aug 2026</p>

<p><strong>Status :</strong>

<span class="pending">Pending</span>

</p>

<p>

<strong>Description :</strong>

Lunch meeting with client.

</p>

</div>

</div>
<footer style="text-align:center;padding:20px;color:#6B7280;font-size:14px;">

© 2026 ClaimSense AI | Expense Management System

</footer>

</main>

</div>

</body>

</html>