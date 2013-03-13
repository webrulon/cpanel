package Cpanel::Easy::Speed;

our $easyconfig = {
    'name'     => 'mod_pagespeed (Author: Prajith)',
    'url'      => 'http://www.prajith.in',
    'note'     => 'mod_pagespeed for Apache 2.x',
    'hastargz' => 1,
    'ensurepkg' => [qw{rpm cpio}],
    'depends'   => { 'optmods' => { 'Cpanel::Easy::Apache::Deflate' => 1, }, },
    'implies'       => { 'Cpanel::Easy::Apache::Deflate' => 1, },
    'src_cd2'  => 'mod_pagespeed/',
    ' when_i_am_off' => sub {
        my ($self) = @_;
             my $unlink_file = "/usr/local/apache/conf/pagespeed.conf";
                      unlink $unlink_file;
                if ( -e $unlink_file ) {
                     $self->print_alert( q{unlink '[_1]' failed: [_2]}, $unlink_file, $! );
                 }
                 $self->strip_from_httpconf(
            'Include "/usr/local/apache/conf/pagespeed.conf"'
        );
    },


    'step'    => {
        '0' => {
                 'name'    => 'Installing mod_pagespeed',
                  'command' => sub {
                       my ($self) = @_;
                       $self->print_alert_color( 'green', 'statring mod_pagespeed installation' );
                       my $path = "speed-install";
                       if ( !-e $path ) {
                          return ( 0, q{speed-install script is missing in source directory} );
                       }
                       my @rc = $self->run_system_cmd_returnable( [ './speed-install' ]);
                       return @rc;
                             },
                         },
        '1' => {
                 'name'    => 'Activating mod_pagespeed',
                 'command' => sub {
                      my ($self) = @_;
                       my $file = '/usr/local/apache/conf/pagespeed.conf';
                        $self->print_alert_color( 'green', 'Activating mod_pagespeed' );
                       $self->strip_from_httpconf('<IfModule pagespeed_module>');
                        return $self->include_directive_handler(
                               {
                                  'include_path' => $file,
                                  'addmodule'    => qr{mod_pagespeed},
                                  'loadmodule'  => qr{pagespeed_module},
                                }
                             );
               },
            },
        },
}
