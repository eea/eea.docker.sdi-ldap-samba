<html>
<body>

  <?php $ip = $_SERVER['REMOTE_ADDR']; ?>

  <form action="samba/auth.php" method="post" style="width: 400px; margin-left: 20px;">
    <fieldset>
      <legend>Create SAMBA Account from EIONET account</legend>
      <?php if (isset($_GET["err"])): ?>
        <span style="color: #F00;">Authentication error - please try again</span><br/>
      <?php endif; ?>

      <label style="width: 130px; display: inline-block;">EIONET Username:</label>
      <input type="text" name="username" size="30" value="" /><br/>

      <label style="width: 130px; display: inline-block;">EIONET Password:</label>
      <input type="password" name="password" size="30" value="" /><br/>
      <div style="text-align: right; margin: 5px 15px 0px 0px;"><input type="submit" value="submit" /></div>
      <small>Your IP address: <?php echo $ip; ?></small>
    </fieldset>
  </form>

</body>
</html>
