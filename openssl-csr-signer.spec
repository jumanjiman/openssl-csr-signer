Name:		openssl-csr-signer
Version:	0.1
Release:	2%{?dist}
Summary:	watches /var/ftp/pub/upload and signs CSRs

Group:		Admin
License:	GPLv3+
URL:		http://github.com/jumanjiman/openssl-csr-signer
Source0:	%{name}-%{version}.tar.gz
BuildRoot:	%(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

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
rm -rf %{buildroot}
mkdir -p %{buildroot}/etc/rc.d/init.d
mkdir -p %{buildroot}/etc/sysconfig
mkdir -p %{buildroot}/usr/local/sbin
install -m755 src/etc/init.d/signerd %{buildroot}/etc/rc.d/init.d
install -m644 src/etc/sysconfig/signerd %{buildroot}/etc/sysconfig
install -m755 src/sbin/signer.pl %{buildroot}/usr/local/sbin
install -m755 src/sbin/casign.exp %{buildroot}/usr/local/sbin


%clean
rm -rf %{buildroot}


%files
%defattr(-,root,root,-)
/etc/rc.d/init.d/signerd
/usr/local/sbin/casign.exp
/usr/local/sbin/signer.pl
/etc/sysconfig/signerd
%doc COPYING



%changelog
* Thu Aug 26 2010 Paul Morgan <jumanjiman@gmail.com> 0.1-2
- add missing file to spec (jumanjiman@gmail.com)

* Thu Aug 26 2010 Paul Morgan <jumanjiman@gmail.com> 0.1-1
- new package built with tito


