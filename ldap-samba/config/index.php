<html>
<head>
<link rel="stylesheet" href="/samba/samba.css">
</head>
<body>

  <?php $ip = $_SERVER['REMOTE_ADDR']; ?>

    <div class='samba'>
         <?php $ip = $_SERVER['REMOTE_ADDR']; ?>

  <form action="/samba/auth.php" method="post">
      Sync SAMBA Account with EIONET
      <br/><br/>
      <?php if (isset($_GET["err"])): ?>
        <span style="color: #F00;">Authentication error - please try again</span>
      <br/>
      <br/>
      <?php endif; ?>
      EIONET Username:
      <br/>
      <input type="text" name="username" size="25" value="" /><br/>
      <br/>
      Password:<br/>
      <input type="password" name="password" size="25" value="" /><br/>
      <br/>
      <input type="submit" value="submit" />

      <br/><br/><br/><br/><br/>
      <small>Your IP address: <?php echo $ip; ?></small>
  </form>
    </div>

</body>
</html>

