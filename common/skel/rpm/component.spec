%define pkgname @NAME@

%global debug_package %{nil}

Name: %{pkgname}
Version: @VERSION@
Release: @RELEASE@%{?dist}
Source: %{pkgname}-%{version}.tar.gz

# Example of declaration of additional sources like .service file
# just put this files in the rpm/ directory
#Source1: @NAME@
#Source2: @NAME@.conf
#Source3: @NAME@.service

URL: @URL@ 
Vendor: @MAINTAINER@
License: @LICENSE@
Group: System/Servers
Summary: @SUMMARY@ 
BuildRoot: %{_tmppath}/%{pkgname}-%{zone}-%{version}-%{release}-build
BuildRequires: systemd-rpm-macros
#BuildArch: noarch
# Build Dependencies
#BuildRequires: systemd-rpm-macros
#BuildRequires: sed
# Runtime Dependencies
#Requires: sed
#Requires: systemd


%description
@DESCRIPTION@

%prep

%setup -q -n %{pkgname}-%{version}

%install

rm -rf -- $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT
#make install \
#    DESTDIR=$RPM_BUILD_ROOT \
#    PREFIX=%{_prefix}


# example of installation of additional sources, here .service and associated files.
#mkdir -p %{buildroot}%{_unitdir} 
#mkdir -p %{buildroot}/usr/lib/tmpfiles.d/ 
#mkdir -p %{buildroot}/etc/sysconfig/ 
#install -pm644 %{SOURCE3} %{buildroot}%{_unitdir} 
#install -pm644 %{SOURCE1} %{buildroot}/etc/sysconfig/ 
#install -pm644 %{SOURCE2} %{buildroot}/usr/lib/tmpfiles.d/


%post
#%systemd_post @NAME@.service
true


%preun
#%systemd_preun @NAME@.service
true


%postun
#%systemd_postun_with_restart @NAME@.service
true

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(644, root, root, 755)
#%{_bindir}/@NAME@
#%{_unitdir}/@NAME@.service
#%config(noreplace) %{_sysconfdir}/@NAME@/@NAME@.conf


%changelog
* Sat Mar 15 2025 @MAINTAINER@ <@MAINTAINER_EMAIL@> 0.0.1-1
- initial Version initiale
