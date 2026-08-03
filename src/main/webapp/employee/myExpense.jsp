<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>My Expenses</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">

<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">

<link rel="stylesheet" href="../assets/css/style.css">

</head>

<body>

<div class="dashboard">

<jsp:include page="../components/sidebar.jsp"/>

<main class="main">

<nav class="topbar">

<h3>My Expenses</h3>

</nav>

<div class="content">

<div class="table-box">

<table>

<tr>

<th>Expense</th>

<th>Category</th>

<th>Amount</th>

<th>Status</th>

</tr>

<tr>

<td>

<a href="expenseDetails.jsp">

Uber Ride

</a>

</td>

<td>Travel</td>

<td>₹450</td>

<td><span class="success">Approved</span></td>

</tr>

<tr>

<td>Starbucks</td>

<td>Food</td>

<td>₹320</td>

<td><span class="pending">Pending</span></td>

</tr>

<tr>

<td>Amazon</td>

<td>Office</td>

<td>₹1250</td>

<td><span class="success">Approved</span></td>

</tr>

</table>

</div>


</div>
<footer style="text-align:center;padding:20px;color:#6B7280;font-size:14px;">

© 2026 ClaimSense AI | Expense Management System

</footer>

</main>


</div>

</body>

</html>