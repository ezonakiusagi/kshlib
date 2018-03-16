#
# spec file for kshlib
#

Name:           kshlib
Version:        0.1
Release:        1%{?dist}
Summary:        ksh library of useful functions
License:        GPLv3
Group:          Development
Source0:        %{name}-%{version}.tar.gz
Requires:       ksh >= 20120801
Requires:       sqlite >= 3.7
Requires:       coreutils
Requires:       findutils
BuildArch:      noarch

%description
This is a library of useful ksh93 functions.

%prep
%setup -q

%build


%install
%{__mkdir} -p ${RPM_BUILD_ROOT}/usr/share/%{name}
%{__mkdir} -p ${RPM_BUILD_ROOT}/usr/share/%{name}/{colorize,logging,sqlite3,tools}
%{__install} -m 644 importlib ${RPM_BUILD_ROOT}/usr/share/%{name}/
%{__install} -m 644 colorize/colorize ${RPM_BUILD_ROOT}/usr/share/%{name}/colorize/
%{__install} -m 644 logging/log_message ${RPM_BUILD_ROOT}/usr/share/%{name}/logging/
%{__install} -m 644 sqlite3/sqlite_close ${RPM_BUILD_ROOT}/usr/share/%{name}/sqlite3/
%{__install} -m 644 sqlite3/sqlite_open ${RPM_BUILD_ROOT}/usr/share/%{name}/sqlite3/
%{__install} -m 644 sqlite3/sqlite_query ${RPM_BUILD_ROOT}/usr/share/%{name}/sqlite3/
%{__install} -m 755 tools/colorize.ksh ${RPM_BUILD_ROOT}/usr/share/%{name}/tools/
%{__install} -m 755 tools/sqlite.ksh ${RPM_BUILD_ROOT}/usr/share/%{name}/tools/
%{__install} -m 755 tools/sqlite-benchmark.ksh ${RPM_BUILD_ROOT}/usr/share/%{name}/tools/

%files
%defattr(-,root,root,-)
%doc README.md LICENSE docs/README.sqlite3
%attr(755,root,root) %dir /usr/share/%{name}
%attr(644,root,root) /usr/share/%{name}/importlib
%attr(755,root,root) %dir /usr/share/%{name}/colorize
%attr(644,root,root) /usr/share/%{name}/colorize/colorize
%attr(755,root,root) %dir /usr/share/%{name}/logging
%attr(644,root,root) /usr/share/%{name}/logging/log_message
%attr(755,root,root) %dir /usr/share/%{name}/sqlite3
%attr(644,root,root) /usr/share/%{name}/sqlite3/sqlite_close
%attr(644,root,root) /usr/share/%{name}/sqlite3/sqlite_open
%attr(644,root,root) /usr/share/%{name}/sqlite3/sqlite_query
%attr(755,root,root) /usr/share/%{name}/tools/colorize.ksh
%attr(755,root,root) /usr/share/%{name}/tools/sqlite.ksh
%attr(755,root,root) /usr/share/%{name}/tools/sqlite-benchmark.ksh

%changelog
* Wed Feb  7 2018 Ezonakiusagi - 0.1-1
- release 0.1
