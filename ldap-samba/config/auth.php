<?php

  // if request is not from inside the EEA, die!
  $ip = $_SERVER['REMOTE_ADDR'];
  //if ($ip != "212.130.111.114") die();
  //if (!in_array($ip,array("10.92.27.219", "10.92.27.233"))) die();

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
  $ds = ldap_connect("ldap://ldap.eionet.europa.eu", 636);
  if ($ds) $booReturn = ldap_bind($ds, "uid=" . $user . ",ou=Users,o=Eionet,l=Europe", $pass);
  if ($booReturn === false)
  {
    header("Location:index.php?err=1");
  }

  echo "Authentication against EIONET was successful, looking up account in local LDAP...<br/>";
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
      echo "Changing Samba password for user " . $user . "...<br/>";
    }

    // set the password
    $output = shell_exec("sudo /usr/local/sbin/smbldap-passwd-wrapper " . $user . " " . $pass . " 2>&1");
    echo "Samba password for user " . $user . " has been set.";
  }
  else
  {
    echo "You already have a valid Samba account on this machine.";
  }
  
  echo "<br/>Please close this page, you may now use the Samba account.";
