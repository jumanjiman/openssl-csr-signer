%global _prefix /usr/local
%global debug_package %{nil}
Name:		openssl-csr-signer
Version:	0.2
Release:	2%{?dist}
Summary:	watches /var/ftp/pub/upload and signs CSRs

Group:		System Environment/Daemons
License:	GPLv3+
URL:		http://github.com/jumanjiman/openssl-csr-signer
Source0:	%{name}-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
buildarch:	noarch

BuildRequires:	tito >= 0.2
Requires:	perl
Requires:	gawk
Requires:	expect

%description
watches /var/ftp/pub/upload and signs CSRs

%prep
%setup -q


%build


%install
%{__rm} -rf %{buildroot}
%{__mkdir_p} %{buildroot}/%{_sysconfdir}/rc.d/init.d
%{__mkdir_p} %{buildroot}/%{_sysconfdir}/sysconfig
%{__mkdir_p} %{buildroot}/usr/local/sbin
%{__install} -p -m755 src/etc/init.d/signerd %{buildroot}/%{_sysconfdir}/rc.d/init.d
%{__install} -p -m644 src/etc/sysconfig/signerd %{buildroot}/%{_sysconfdir}/sysconfig
%{__install} -p -m755 src/sbin/signer.pl %{buildroot}/%{_sbindir}
%{__install} -p -m755 src/sbin/casign.exp %{buildroot}/%{_sbindir}


%clean
%{__rm} -rf %{buildroot}


%files
%defattr(-,root,root,-)
/%{_sysconfdir}/rc.d/init.d/signerd
%{_sbindir}/casign.exp
%{_sbindir}/signer.pl
/%{_sysconfdir}/sysconfig/signerd
%doc COPYING



%changelog
* Sat Aug 28 2010 Paul Morgan <jumanjiman@gmail.com> 0.2-2
- build as noarch (jumanjiman@gmail.com)

* Sat Aug 28 2010 Paul Morgan <jumanjiman@gmail.com> 0.2-1
- do not build debuginfo; version bump (jumanjiman@gmail.com)

* Sat Aug 28 2010 Paul Morgan <jumanjiman@gmail.com> 0.1-3
- clean up spec file (jumanjiman@gmail.com)
- Added appropriate comments to the expect script and gave credit to the
  authors (narkoleptik@gmail.com)
- Cleaned up some of the things I left out before.  Also, added variables for
  the binary directories rather than hard coding them in.
  (narkoleptik@gmail.com)

* Thu Aug 26 2010 Paul Morgan <jumanjiman@gmail.com> 0.1-2
- add missing file to spec (jumanjiman@gmail.com)

* Thu Aug 26 2010 Paul Morgan <jumanjiman@gmail.com> 0.1-1
- new package built with tito


