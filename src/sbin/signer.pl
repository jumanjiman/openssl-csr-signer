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

# Setup our variables
$dir = "/var/ftp/upload";
$certdir = "/var/ftp/pub/certs";
$oldcertdir = "/tmp";
$bindir = "/usr/local/sbin";

# Informative output
print "Watching $dir\n";
# Sets up our output buffer, ok, it's not a real buffer, but whatever, 
# it's free, and it works.
$line = "";
# Populates an array with the current list of files in the directory we
# are wanting to watch.
@files=<$dir/*>;
# Counts the number of files
$lastfiles=scalar(@files);
# Loops until killed with ctrl-c
while (true) {
	# Gets the current list of files
	@files=<$dir/*>;
	# Compares count to the previous count, if different, it does our 
	# signing.  If they are the same, it just sleeps.
	if ( scalar(@files) gt $lastfiles) {
		opendir(DIR,"$dir") or die "Can't open $dir\n";
		while ($filename = readdir(DIR)) {
			if (($filename ne ".") && ($filename ne "..")) {
				print "Working with $filename\n";

				# This part just gives some consistency to the names
				# of our uploaded files.  From time to time, people would
				# copy in the wrong extension of say "crs" rather than 
				# "csr", so I decided to just make them all have .csr
				($name, $ext) = split(/\./, $filename);
				if ($ext ne "csr") {
					print "Renaming $filename $name.csr\n";
					rename("$dir/$filename", "$dir/$name.csr");
				}
				
				# This is where we call the expect script.  In reality, 
				# this can be done with a perl module for expect, but I
				# haven't learned about that yet. So, for now, we're 
				# calling an external method.
				#
				# The exit code here is read from what is sent back from
				# expect script. This was the best way I could find to 
				# handle error sharing between the external expect script
				# and the calling perl script.
				$exit = system("$bindir/casign.exp $dir/$name.csr $certdir/$name.crt");
				# Purely here for debugging purposes.  Should probably take
				# it out, but for now, it is useful.
				print "\n$exit <--- exit code\n";
				# Probably not necessary to sleep this long, but this gives
				# ample time to see the error message. Not that anybody
				# ever reads errors, but it makes me feel warm and fuzzy
				# just knowing it is here.
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

				# Cleaning up.  Moves the csr files out of the way and goes
				# back to watching for new files.
				print "Moving $dir/$name.csr to $oldcertdir/name.csr\n";
				system("mv $dir/$name.csr $oldcertdir/$name.csr-`date +%s`");
				print "Watching $dir for uploads\n";
			}
		}
		closedir(DIR);
		# And here, we start all over again.
		@files=<$dir/*>;
		$lastfiles=scalar(@files);
	}
}
