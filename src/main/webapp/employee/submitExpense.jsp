<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">

<title>Submit Expense</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">

<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">

<link rel="stylesheet" href="../assets/css/style.css">

</head>

<body>

<div class="dashboard">

<jsp:include page="../components/sidebar.jsp"/>

<main class="main">

<nav class="topbar">

<h3>Submit Expense</h3>

</nav>

<div class="content">

<div class="table-box">

<h4>New Expense</h4>

<div class="row">

<div class="col-md-6">

<label>Expense Title</label>

<input class="form-control" placeholder="Business Lunch">

</div>

<div class="col-md-6">

<label>Category</label>

<select class="form-control">

<option>Travel</option>

<option>Food</option>

<option>Office Supplies</option>

<option>Accommodation</option>

</select>

</div>

<div class="col-md-6 mt-3">

<label>Amount</label>

<input class="form-control" placeholder="₹ 0">

</div>

<div class="col-md-6 mt-3">

<label>Date</label>

<input type="date" class="form-control">

</div>

<div class="col-12 mt-3">

<label>Description</label>

<textarea class="form-control" rows="5"></textarea>

</div>

<div class="col-12 mt-3">

<label>Upload Receipt</label>

<input type="file" class="form-control">
<p style="font-size:13px;color:#6B7280;margin-top:8px;">

Supported Files:
JPG, PNG, PDF

</p>

</div>

<div class="col-12 mt-4">

<button class="btn btn-primary">

Submit Expense

</button>

</div>

</div>

</div>

</div>
<footer style="text-align:center;padding:20px;color:#6B7280;font-size:14px;">

© 2026 ClaimSense AI | Expense Management System

</footer>

</main>

</div>

</body>

</html>