# Generated from ip-wrangler-0.1.1.gem by gem2rpm -*- rpm-spec -*-
%global gemname ip-wrangler

#%global gemdir %(ruby -rubygems -e 'puts Gem::dir' 2>/dev/null)
%global gemdir /usr/share/gems
%global geminstdir %{gemdir}/gems/%{gemname}-%{version}
%global rubyabi 2.0.0

Summary: Service is responsible for managing DNAT rules in iptables nat table
Name: rubygem-%{gemname}
Version: 0.1.2
Release: 1%{?dist}
Group: Development/Languages
License: MIT
URL: https://github.com/dice-cyfronet/ip-wrangler
Requires: ruby(release) = %{rubyabi}
Requires: ruby(rubygems) 
Requires: rubygem(json) < 2
Requires: iptables >= 1.4
Requires: lsof
Requires: sudo
Requires: sqlite >= 3
Requires: openssl
Requires: zlib
BuildRequires: ruby(release) = %{rubyabi}
BuildRequires: ruby(rubygems) 
BuildRequires: ruby 
BuildArch: x86_64
Provides: rubygem(%{gemname}) = %{version}

%description
Iptables DNAT manager.

%prep
%setup -q -c -T

mkdir -p .%{gemdir}
mkdir -p .%{_bindir}
cd %{_sourcedir}
gem fetch %{gemname} -v %{version}
cd -
gem install --no-rdoc --no-ri --install-dir .%{gemdir} \
            --bindir .%{_bindir} \
            --force %{_sourcedir}/%{gemname}-%{version}.gem
%build

%install
mkdir -p %{buildroot}%{gemdir}
cp -pa .%{gemdir}/* \
        %{buildroot}%{gemdir}/

mkdir -p %{buildroot}%{_bindir}
cp -pa .%{_bindir}/* \
        %{buildroot}%{_bindir}/

find %{buildroot}%{geminstdir}/bin -type f | xargs chmod a+x

%post
if [ `grep -c ^ip-wrangler /etc/passwd` = "0" ]; then
  /usr/sbin/useradd -c 'ip-wrangler sevice user' ip-wrangler
fi

mkdir /usr/share/gems/gems/ip-wrangler-0.1.2/lib/log
chown ip-wrangler:ip-wrangler /usr/share/gems/gems/ip-wrangler-0.1.2/lib/log

echo "ip-wrangler `cat /etc/hostname`= NOPASSWD: /sbin/iptables, /usr/bin/lsof" >> /etc/sudoers

ln -s  %{geminstdir}/support/systemd/ip-wrangler.service /etc/systemd/system/ip-wrangler.service

printf "\n*** You have successfully installed ip-wrangler! \nPlease run following command before starting the service:\n"
printf "ip-wrangler-configure /etc/ip-wrangler.yml && chmod 600 /etc/ip-wrangler.yml && chown ip-wrangler /etc/ip-wrangler.yml\n"
printf "*** Notice! Remember to properly configure SELinux!\n\n"

%files

%{gemdir}/gems
%{_bindir}/ip-wrangler-clean
%{_bindir}/ip-wrangler-clean.sh
%{_bindir}/ip-wrangler-configure
%{_bindir}/ip-wrangler-configure.sh
%{_bindir}/ip-wrangler-start
%{_bindir}/ip-wrangler-start.sh
%{_bindir}/ip-wrangler-stop
%{_bindir}/ip-wrangler-stop.sh
%{_bindir}/ip-wrangler-test
%{_bindir}/ip-wrangler-test.sh
%{_bindir}/sequel
%{_bindir}/thin
%{_bindir}/rackup
%{_bindir}/tilt

%exclude %{gemdir}/doc
%exclude %{gemdir}/cache

%{gemdir}/specifications

%changelog
* Mon Apr 20 2015 root <rpmbuild@localhost.localdomain> - 0.1.2-1
- ip-wrangler version changed 
* Fri Mar 20 2015 root <rpmbuildt@localhost.localdomain> - 0.1.1-1
- Initial package

