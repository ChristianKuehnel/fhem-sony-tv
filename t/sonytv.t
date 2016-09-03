use strict;
use warnings;
use v5.10.1;
use experimental "smartmatch";
use Test::More;
use Time::HiRes "gettimeofday";
use Test::MockModule;

use lib "t"; 
use fhem_test_mocks;
use SONYTV;

##############################################################################################
test_timeout();
test_json_parse_error();
test_parse_nonsense_json();
test_parse_active();
test_parse_something();

#last line in test sequence
done_testing();
##############################################################################################

sub test_timeout {
    main::reset_mocks();
    my $hash = {
        NAME => "dummy",
    };
    my $param = {
        hash => $hash,
    };
    my $err = "network connection timed out";
    my $data = undef;
    set_fhem_mock("deletereading dummy error_message");
    SONYTV::getPowerStatus_response($param,$err,$data);
    is($hash->{STATE},"offline");
}

sub test_json_parse_error {
    main::reset_mocks();
    my $hash = {
    	NAME => "dummy",
    };
    my $param = {
    	hash => $hash,
    };
    my $err = undef;
    my $data = "some non-json text";
	SONYTV::getPowerStatus_response($param,$err,$data);
	is($hash->{STATE},"ERROR");
}

sub test_parse_nonsense_json {
    main::reset_mocks();
    my $hash = {
        NAME => "dummy",
    };
    my $param = {
        hash => $hash,
    };
    my $err = undef;
    my $data = '{"some":"other text"};';
    SONYTV::getPowerStatus_response($param,$err,$data);
    is($hash->{STATE},"ERROR");
}


sub test_parse_active {
    main::reset_mocks();
    my $hash = {
        NAME => "dummy",
    };
    my $param = {
        hash => $hash,
    };
    my $err = undef;
    my $data = '{"result":[{"status":"active"}]}';
    set_fhem_mock("deletereading dummy error_message");
    SONYTV::getPowerStatus_response($param,$err,$data);
    is($hash->{STATE},"active");
}

sub test_parse_something {
    main::reset_mocks();
    my $hash = {
        NAME => "dummy",
    };
    my $param = {
        hash => $hash,
    };
    my $err = undef;
    my $data = '{"result":[{"status":"something"}]}';
    set_fhem_mock("deletereading dummy error_message");
    SONYTV::getPowerStatus_response($param,$err,$data);
    is($hash->{STATE},"something");
}


#  end of file #################
1;