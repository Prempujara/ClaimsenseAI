<%@ page contentType="text/html;charset=UTF-8" language="java"%>

<!DOCTYPE html>
<html>

<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Employee Dashboard</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet">

<link rel="stylesheet" href="../assets/css/style.css">

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

</head>

<body>

<div class="dashboard">

   <jsp:include page="../components/sidebar.jsp"/>

    <main class="main">

        <nav class="topbar">

            <div>

<h3 style="margin:0;">Good Evening, Prem 👋</h3>

<p style="margin:0;color:#6B7280;">

Welcome back to ClaimSense AI

</p>

</div>

            <div>

                <i class="fa-regular fa-bell"></i>

            </div>

        </nav>

        <div class="content">
        <div style="margin-bottom:25px;">

    <h2>Good Evening, Prem 👋</h2>

    <p style="color:#6B7280;">
        Welcome back! Here's today's expense overview.
    </p>

</div>

   <div class="cards">

    <div class="card">

        <span>💰 Total Expense</span>

        <h2>₹28,500</h2>

    </div>

    <div class="card">

        <span>⏳ Pending</span>

        <h2>08</h2>

    </div>

    <div class="card">

        <span>✅ Approved</span>

        <h2>16</h2>

    </div>

    <div class="card">

        <span>❌ Rejected</span>

        <h2>03</h2>

    </div>

</div>
<div class="table-box" style="margin-bottom:25px;">

    <div style="display:flex;justify-content:space-between;align-items:center;">

        <h4>🤖 AI Assistant Status</h4>

        <span class="success">Active</span>

    </div>

    <hr>

    <div style="margin-top:20px;">

        <p>✔ OCR Receipt Scanner Ready</p>

        <p>✔ Smart Expense Categorization</p>

        <p>✔ Fraud Detection Engine</p>

        <p>✔ AI Expense Insights</p>

    </div>

</div>
            <div class="dashboard-grid">

                <div class="table-box">

                    <h4>Recent Expenses</h4>

                    <table>

                        <tr>

                            <th>Expense</th>

                            <th>Category</th>

                            <th>Amount</th>

                            <th>Status</th>

                        </tr>

                        <tr>

                            <td>Uber</td>

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
                        <tr>

<td>Amazon</td>

<td>Office</td>

<td>₹1250</td>

<td><span class="success">Approved</span></td>

</tr>

                    </table>

                </div>

                <div class="chart-box">

                    <h4>Expense Breakdown</h4>

                    <canvas id="expenseChart"></canvas>

                </div>

            </div>

        </div>
        <footer style="text-align:center;padding:20px;color:#6B7280;font-size:14px;">

© 2026 ClaimSense AI | Expense Management System

</footer>

    </main>

</div>

<script>

new Chart(document.getElementById("expenseChart"),{

	type:'doughnut',

	data:{

	labels:["Travel","Food","Office"],

	datasets:[{

		data:[55,20,25],

	backgroundColor:[
	"#2563EB",
	"#10B981",
	"#F59E0B"
	]

	}]

	}

	});
</script>

</body>

</html>