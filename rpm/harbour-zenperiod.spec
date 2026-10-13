Name:       harbour-zenperiod
Summary:    Privacy-focused period and PMS tracker, fully offline
Version:    0.1
Release:    2
Group:      Qt/Qt
License:    GPL-3.0-only
URL:        http://example.org/
Source0:    %{name}-%{version}.tar.bz2

Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires: pkgconfig(sailfishapp) >= 1.0.2
BuildRequires: pkgconfig(Qt5Core)
BuildRequires: pkgconfig(Qt5Qml)
BuildRequires: pkgconfig(Qt5Quick)
BuildRequires: pkgconfig(Qt5Sql)
BuildRequires: desktop-file-utils

%description
Local-only period and PMS tracker. No account, no cloud, no tracking.
Cycle predictions are computed on-device from logged data and are not
medical advice.

%prep
%setup -q -n %{name}-%{version}

%build
%qmake5 harbour-zenperiod.pro
%make_build

%install
rm -rf %{buildroot}
%qmake5_install

%files
%defattr(-,root,root,-)
%{_bindir}/harbour-zenperiod
%{_datadir}/harbour-zenperiod
%{_datadir}/applications/harbour-zenperiod.desktop
%{_datadir}/icons/hicolor/*/apps/harbour-zenperiod.png
