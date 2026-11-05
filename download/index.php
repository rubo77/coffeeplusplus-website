<?
function document_write($text){
	$r=explode("\n", $text);
	for ($i=0; $i<sizeof($r); $i++){#&rsquo;lsquo
		$ret.="document.write('".str_replace("'", "&quot;",  chop($r[$i]) )."');\n";
	}
	return $ret;
}
function javascript($text){
	return '<script language="JavaScript1.2">
	<!-- //
	'.$text.'
	// -->
	</script>';
}
function alert($text){
	echo '<script language="JavaScript1.2">
	<!-- //
		alert(\''.$text.'\');
	// -->
	</script>';
}

?><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
	<title>Download Coffee++</title>
	<link rel="STYLESHEET" type="text/css" href="../../style-v2.php">
</head>

<body bgcolor="#d7c39a">
<?


?>
<table border="0">
	
    <tr>
		<td align="center">
		    <table border="0">
			<tr>
		    	<td nowrap>
<?php
	function sort2d($a){
		$name=$a["name"];
		sort ($name);
		for ($y=0; $y<sizeof($name); $y++) {
			$x=0;
			while ($name[$x]<>$a["name"][$y]) $x++;
			$typ[$x]=$a["typ"][$y];
		}
		$a["name"]=$name;
		$a["typ"]=$typ;
		return $a;
	}
	
	$maxfilme="24";
	$datum=date("d.M.Y");
	$zeit=date("H:i");
	$sicher=TRUE;

	$hoehe=10; // nach hoehe zeilen wird in der naechsten weitergeschrieben
	$p=explode("/", $SCRIPT_FILENAME);
	for ($i=0; $i<sizeof($p)-1; $i++) $localdir=$localdir.$p[$i].'/';
	$pfad=str_replace("..", ".",rawurldecode($pfad));
	if ($pfad=="") $pfad=".";
	else $pfad=substr($pfad, 0-(strlen($pfad)));
		
	$p=explode("/", $pfad);
	if ($p[1]<>"") echo '<font color="maroon">Directory: '.$pfad.'</font><br>';
	?>
	<script language="JavaScript">
	  <!-- //
	  function wechsel(name){
	  	document.merk.src="/pics/check.php?benutzer=<? echo $benutzer; ?>&name="+name;
		return true;
	  }
	  
	  // -->
	  </script>
	<table border="0">
	<form name="auswahlform" action="/cgi-bin/streamcast.cgi" method=post>
		<tr>
			<td nowrap width="600">
	<?
	$handlepfad=str_replace("\\'", "'", $pfad);
	#echo $preg="/".str_replace("/", "\/",preg_quote($PHP_SELF))."$/";
	$totalpfad=preg_replace("/index\.php$/", "",$_SERVER["PATH_TRANSLATED"]).preg_replace('/^\.\/*/', '', $pfad);
	if (! $handle=opendir($handlepfad)) echo $handlepfad."<br>";
	$i=0;
	
	$linkanfang='<a href="/cgi-bin/streamcast.cgi?action=show_info&songid='; // fehlt nur noch ">
	$checkboxanfang='<input type=checkbox name=songid value="';
	$checkboxende='">';
	$formende='<input type=hidden name=action value=add_request>
		<input type=submit value="Die ausgew�hlten titel im Radio w�nschen">';
	
	while ($file["name"][$i] = readdir($handle)) {
		$neu= $localdir.$pfad.'/'.$file["name"][$i]."/";
		//echo "p=".$neu.'!!!<br>';
		if (@chdir(stripslashes($neu))) $file["typ"][$i]="dir"; 
		else {
			$t=explode(".", $file["name"][$i]);
			$ending=$t[sizeof($t)-1];
			$file["typ"][$i]=$ending;
			
			#echo "error:".$ending."<br>";
		}
		$i++;
	}
		$file=sort2d($file);
		for ($xy=0;$xy<=1;$xy++){ //schneller dreckiger patch, um dirs oben anzuzeigen
			
		    for ($i=2; $i<sizeof($file["name"]); $i++) {
			
				if (($xy==0 and $file["typ"][$i]=="dir") or ($xy==1 and $file["typ"][$i]<>"dir")){ // auch dreckiger patch
					$p=explode("/", $pfad);
					//echo "typ=".$file["typ"][$i]."<br>";
					if ($i==2 and $sicher==TRUE and $pfad==".") echo "<br>";
					elseif ($file["typ"][$i]=="dir") { 
						if ($i==2) {
							for ($pz=1, $npfad="."; $pz<sizeof($p)-1; $pz++) $npfad=$npfad."/".$p[$pz];
							echo '&nbsp; <a href="index.php?pfad='.rawurlencode(str_replace("//", "/",$npfad)).'">('.$file["name"][$i].')</a><br>'."\n";
						}
						elseif ($file["name"][$i]<>"upload" 
							and $file["name"][$i]<>"html" 
						    and $file["name"][$i]<>".AppleDouble" 
						    and $file["name"][$i]<>"anderes") echo '&nbsp; <a href="index.php?pfad='.rawurlencode($pfad.'/'.$file["name"][$i]).'" style="font: bold;">['.$file["name"][$i].']</a><br>'."\n";
					}
					elseif ($file["typ"][$i]<>"htaccess" 
						and strtoupper($file["typ"][$i])<>"PHP3" 
						and strtoupper($file["typ"][$i])<>"PHP" 
						and strtoupper($file["typ"][$i])<>"HTML" 
						and $file["name"][$i]<>"upload"
						and $file["name"][$i]<>"Hirnbrand Archiv Suche.url"
						or $file["name"][$i]=="info.php"
						) {
						$thistotalname=stripslashes($totalpfad.'/'.$file["name"][$i]);
						$filesize=round((@filesize($thistotalname)/(1024*1024)),2);
						if ($filesize<=0.6 and in_array(strtoupper($file["typ"][$i]),array("JPG","GIF","JPEG","PNG"))) {
								$imagesize=getimagesize($thistotalname);
								// [0]=>  int(1201) [1]=>  int(929) [2]=>  int(2) [3]=>  string(25) "width="1201" height="929"" 
								echo '<table align="right"><tr><td><img src="'.str_replace("%2F", "/", rawurlencode($pfad.'/'.$file["name"][$i])).'" ';
								if ($imagesize[0]>200) echo 'width="200"';
								echo '></td><td>'.$file["name"][$i].'<br>'.$imagesize[0]."x".$imagesize[1]." px";
								echo "</td></tr></table>";
						}
						if (strtoupper($file["typ"][$i])<>"MP3") {
							if ($file["name"][$i]=="info.php") echo '<a href="info.php"><b>Info</b></a><br>'."\n";
							else {
								echo '- <a href="'.str_replace("%2F", "/", rawurlencode($pfad.'/'.$file["name"][$i])).'">'.$file["name"][$i].'</a> <font style="font-size:9pt;">(';
								$thistotalname=stripslashes($totalpfad.'/'.$file["name"][$i]);
								
								echo round((@filesize($thistotalname)/(1024*1024)),2).' mb)</font><br>'."\n";
							}
						} else {	
							$titel1=$pfad.'/'.$file["name"][$i];
							$mytitel=$handlepfad.'/'.$file["name"][$i];
							$apos=strpos($titel1, "archiv");
							if ($apos<2) $apos=strpos($titel1, "download");
							if ($apos<2) $apos=strpos($titel1, "Hoerspiele");
							$titel=substr($titel1, $apos);
							$mp3pfad=str_replace("//", "/", str_replace("'", "\\'", strtolower($titel)));
							if (!$c2) {
								$db2="chart"; 
								$host="localhost"; 
								$user="root"; 
								$pw=""; 
								$c2 = mysql_connect($host, $user, $pw); 
							}
							$stmt="SELECT songid FROM playlist where titel like
								'/musikarchiv/archiv/".substr(str_replace("//", "/", str_replace("'", "\\'", $mytitel)), 5)."\n'";
							#$stmt="SELECT songid FROM playlist where titel like '/musikarchiv/archiv/'".substr($titel1, 2)."\n'";
							#echo $stmt."<br>";
							if (!($ergebnis=mysql_db_query($db2, $stmt))) echo $stmt."<br>";
							$row=mysql_fetch_array($ergebnis);
							//if ($row["songid"]<>"") $vorlink=$checkboxanfang.$row["songid"].$checkboxende;
							//else $vorlink="-&nbsp; ";
								
							//if (strlen($file["name"][$i])>50) echo  '<table border="0" cellpadding="0" cellspacing="0"><tr><td valign="top">'.$vorlink.'</td><td>'; // damit nowrap aus ist
							//else echo $vorlink;
							$titelmitslashs=str_replace("%2F", "/", rawurlencode($titel));
							echo '- <a href="http://'.$SERVER_ADDR.'/intern/'.str_replace('%5C%27', '%27', $titelmitslashs).'" onclick="wechsel('."'$titelmitslashs'".')">'.$file["name"][$i].'</a> <font style="font-size:8pt;">(';
							echo round((filesize(stripslashes($totalpfad.'/'.$file["name"][$i]))/(1024*1024)),2).' mb)</font>';
							if ($row["songid"]<>"") {
								//echo " &nbsp;".$linkanfang.$row["songid"].'" target="info" onclick="window.open('."'','info','width=770,height=520,left=0, top=0,scrollbars=1,menubar=no,locationbar=no,resizable=yes'".')" title="info"><font size="+1"><b> i </b></font></a>';
								// ----------Zum W�nschen:
								echo ' &nbsp;<a href="/radio/cdwunsch.php3?name='.$benutzer.'&id='.$row["songid"].'" " target="cdwunsch" onclick="window.open('."'','cdwunsch','width=770,height=520,left=0, top=0,status=1,scrollbars=1,menubar=no,locationbar=no,resizable=yes'".')" title="zur wunschliste hinzuf�gen"><font size="+1"><b>w</b></font></a>';
								$formda=TRUE;
							}
							#/* wenn die hits in den charts angezeigt werden sollen:
							$stmt="SELECT count(*) as counter, s.song_id 
									FROM mychart_songs s,mychart_log l
									 where titel like '".substr(str_replace("//", "/", str_replace("'", "\\'", $mytitel)), 5)."'
									 and l.song_id=s.song_id 
									 group by s.song_id
									 ";
							if (!($ergebnis=mysql_db_query($db2, $stmt))) echo $stmt."<br>".mysql_error()."<br>";
							if($row=mysql_fetch_array($ergebnis)){
								#var_dump($row);
							}
							if ($row["counter"]=="") $row["counter"]="0";
							echo ' &nbsp; ';
							if ($row["song_id"]>0) echo '<a href="/mycharts/songinfo.php?song_id='.$row["song_id"].'" target="info" onclick="window.open(this.href,this.target,\'width=350,height=400,screenx=220,screeny=220,locationbar=no,menubar=no,status=no,scrollbars=yes,resizable=yes\')">';
							echo '('.$row["counter"].')</a>';
							echo ''."\n";
							#*/
							//echo "</i>";
							//if (strlen($file["name"][$i])>25) echo  '</td></tr></table>';
							//else echo "<br>\n";
							echo "<br>\n";
						}
					}
					//if ($hz++==15) {
					//	echo '</span>
					//	    </td>
					//	    <td valign="top" nowrap>
					//		<span id="whitegrtext"><br>';
					//	$hz=1;
					//}
					
			    }
			}
		}
	    closedir($handle); 

	    ?>
    
								</td>
						    </tr>
			        	</table>
			    	</td>
		        </tr>
		    </table>
		</td>
	</tr>
	<tr>
		<td colspan="2"><hr></td>
	</tr>
	<tr>
		<td nowrap>
		    <br>
		</td>
    </tr>
    </table>
	<img name="merk" src="/pics/1x1.gif" width="1" height="1" alt="" border="0">
<?//}?>
</body>
</html>

