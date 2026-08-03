<%@ page contentType="text/html;charset=UTF-8"%>

<!DOCTYPE html>

<html>

<head>

<meta charset="UTF-8">

<title>Manager Dashboard</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">

<link rel="stylesheet" href="../assets/css/style.css">

</head>

<body>

<div class="dashboard">

<jsp:include page="../components/sidebar.jsp"/>

<main class="main">

<nav class="topbar">

<h3>Pending Approvals</h3>

</nav>

<div class="content">

<div class="table-box">

<table>

<tr>

<th>Employee</th>

<th>Expense</th>

<th>Amount</th>

<th>Action</th>

</tr>

<tr>

<td>Prem Pujara</td>

<td>Business Lunch</td>

<td>₹650</td>

<td>

<button class="btn btn-success">

Approve ✓

</button>

<button class="btn btn-danger">

Reject ✕

</button>

</td>

</tr>

<tr>

<td>Rahul Sharma</td>

<td>Flight Ticket</td>

<td>₹7500</td>

<td>

<button class="btn btn-success">

Approve

</button>

<button class="btn btn-danger">

Reject

</button>

</td>

</tr>

</table>

</div>

</div>

</main>

</div>

</body>

</html>