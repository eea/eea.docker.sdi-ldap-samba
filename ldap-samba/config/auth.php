<html>
<head>
<link rel="stylesheet" href="samba.css">
</head>
<body>

<?php
  echo "<div class='samba'>";
  //putenv('LDAPTLS_REQCERT=never');
  // if request is not from inside the EEA, die!
  $ip = $_SERVER['REMOTE_ADDR'];

  $post = $_POST;
  if (empty($post))
  {
     header ("Location: index.php?err=1");
     exit(0);
  }

  $user = $post["username"];
  $pass = $post["password"];

  if (!$user || !$pass)
  {
    header("Location:index.php?err=1");
  }

  $booReturn = false;
  $ds = ldap_connect('ldaps://ldap.eionet.europa.eu');
  if ($ds) $booReturn = ldap_bind($ds, "uid=" . $user . ",ou=Users,o=Eionet,l=Europe", $pass);
  if ($booReturn === false)
  {
    header("Location:index.php?err=1");
  }

//  echo "<br/>Authentication against EIONET was successful, looking up account in local LDAP...<br/><br/><br/>";
  $booReturn = false;
  $ds = ldap_connect("127.0.0.1");
  if ($ds) $booReturn = ldap_bind($ds, "uid=" . $user . ",ou=Users,dc=eea,dc=europa,dc=eu", $pass);

  if ($booReturn === false)
  {
    // try to create a new user
    $output = shell_exec("sudo /usr/sbin/smbldap-useradd -a " .  $user);

    // we already have this user, change password
    if (preg_match("/user " . $user . " exists/", $output))
    {
      echo "<br/>Changing Samba password for user " . $user . "...<br/><br/>";
    }

    // set the password
    $output = shell_exec("sudo /usr/local/sbin/smbldap-passwd-wrapper " . $user . " " . $pass);
    echo "Samba password for user " . $user . " has been set.<br/><br/>";
    $output = shell_exec("/updateSingleSID.sh " . $user);
  }
  else
  {
    echo "<br/>Your Samba account is already in sync with LDAP on this machine.<br/><br/><br/><br/>";
  }

  echo "<br/><br/><br/>Please close this page, you may now use the Samba account.<br/><br/>";

  echo "</div>";

?>
</body>
</html>
