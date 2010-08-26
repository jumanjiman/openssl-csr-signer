#!/usr/bin/perl
# Author: Brad McDuffie <bmcduffi@redhat.com>
# Thu Aug 19 21:21:10 MDT 2010
# Perl script to automate signing CSRs in a specified directory.
#
# Description:
# This script watches /var/ftp/upload and signs CSR files automatically and
# places them in the /var/ftp/pub/certs directory. If the signing fails, it
# will remove the zero byte file from the certs dir.  Either way, it moves 
# the csr file to /tmp and names it with a timestamp.
#
# This script expects an expect script to be in /usr/local/sbin/ named
# casign.exp.  The original of that script was written by
# Brandon Perkins <bperkins@redhat.com>

$dir = "/var/ftp/upload";
$certdir = "/var/ftp/pub/certs";
$oldcertdir = "/tmp";

system(clear);
print "Watching $dir\n";
$line = "";
@files=<$dir/*>;
$lastfiles=scalar(@files);
while (true) {
	@files=<$dir/*>;
	if ( scalar(@files) gt $lastfiles) {
		opendir(DIR,"$dir") or die "Can't open $dir\n";
		while ($filename = readdir(DIR)) {
			if (($filename ne ".") && ($filename ne "..")) {
				print "Working with $filename\n";
				($name, $ext) = split(/\./, $filename);
				if ($ext ne "csr") {
					print "Renaming $filename $name.csr\n";
					rename("$dir/$filename", "$dir/$name.csr");
				}

				# This exit code is always getting set to be 0, and I
				# haven't figured out how to get expect to return the 
				# error codes.
				$exit = system("/usr/local/sbin/casign.exp $dir/$name.csr $certdir/$name.crt");
				print "$exit <--- exit code\n";
				sleep 10;

				if ($exit eq 0) {
					system(clear);
					print "--------------------------\n";
					$line = $line . "Done signing $name.csr\n";
					print $line;
				}
				else {
					system("rm $certdir/$name.crt");
					system(clear);
					print "-----------------------------------------\n";
					$line = $line . "There was a problem with $name.csr <-- upload a fixed CSR\n";
					print $line;
					print "-----------------------------------------\n";
				}
				print "Moving $dir/$name.csr to $oldcertdir/name.csr\n";
				system("mv $dir/$name.csr $oldcertdir/$name.csr-`date +%s`");
				print "Watching $dir for uploads\n";
			}
#			else {
#				print "$file\n";
#			}
		}
		closedir(DIR);
		@files=<$dir/*>;
		$lastfiles=scalar(@files);
	}
}

#foreach(@files) {
#	print "$_\n";
#}
