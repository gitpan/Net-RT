use Module::Build;
my $build = new Module::Build
  (
   module_name => 'Net::RT',
   license => 'perl',
   requires => {
                perl           => '5.6.1',
                SOAP::Lite   => '0.55',
                #Other::Module  => '>= 1.2, != 1.5, < 2.0',
               },
  );
$build->create_build_script;
