require boxen::environment
require homebrew

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  include textmate::textmate2::beta     # beta releases
  include iterm2::dev
  include osxfuse
  class { 'vagrant':
    completion => true,
  }
  vagrant::plugin { 'landrush': prefix => ''}
  # include vim
  vim::bundle { 'Lokaltog/vim-distinguished': }
  # include cyberduck

  osx::recovery_message { 'You lost the game': }

  include osx::global::disable_key_press_and_hold
  include osx::global::enable_keyboard_control_access
  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog
  include osx::global::disable_remote_control_ir_receiver
  include osx::dock::autohide
  include osx::dock::disable_dashboard
  include osx::dock::dim_hidden_apps
  include osx::finder::show_all_on_desktop
  include osx::finder::unhide_library
  include osx::disable_app_quarantine
  include osx::no_network_dsstores
  include osx::software_update
  class { 'osx::global::key_repeat_delay':
    delay => 15
  }
  class { 'osx::global::key_repeat_rate':
    rate => 2
  }
  include osx::keyboard::capslock_to_control
  class { 'osx::global::natural_mouse_scrolling':
    enabled => false
  }
  class { 'osx::dock::position':
    position => 'left'
  }
  class { 'osx::dock::hot_corners':
    bottom_right => "Start Screen Saver",
    bottom_left  => "Desktop",
  }
  class { 'gpgtools': }
  class { 'docker':
    version => '1.6.0'
  }
  include gitx::dev
  # include libreoffice
  include vagrant_manager
  include tunnelblick::beta
  include fluid
  include chrome
  include omnigraffle
  include omnigraffle::pro
  include ipmitool
  include nmap
  include transmission
  include openssl
  include zshgitprompt
  include zsh
  # include induction
  include caffeine
  # include java
  # include trailer
}

