#Copyright 2016 Christian Kühnel
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.    

use v5.10.1;
use warnings;
use strict;

use JSON;
use Time::HiRes;
 
# fhem integration ####################################################
package main;
 
 sub SONYTV_Initialize {
    my ($hash) = @_;
    $hash->{DefFn}      = 'SONYTV_Define';
    #$hash->{UndefFn}    = 'SONYTV_Undef';
    $hash->{SetFn}      = 'SONYTV_Set';
    #$hash->{GetFn}      = 'SONYTV_Get';
    #$hash->{AttrFn}     = 'SONYTV_Attr';
    #$hash->{ReadFn}     = 'SONYTV_Read';    
    #$hash->{NotifyFn}     = 'SONYTV_Notify';
    $hash->{AttrList} = "interval";
    $hash->{parseParams} = 1;
    return;
}

sub SONYTV_Define {
    my ($hash, $a, $h) = @_;   
    my $host_name = $a->[2];
    $hash->{host_name} = $host_name; 
    $hash->{STATE} = "defined";
    InternalTimer(gettimeofday()+2, "SONYTV_poll", $hash, 0);   
    
    return 0;
}

sub SONYTV_Set {  
    my ( $hash, $a,$h ) = @_;
    my $cmd = $a->[1];
    if ( $cmd eq "?" ){
        return "update:noArg";
    } elsif ( $cmd eq "update" ) {
    	SONYTV::getPowerStatus($hash);
    }
    
    return 0;
}

sub SONYTV_poll {
    my ($hash) = @_;
    Log(5,"$hash->{NAME}: cyclic polling");
    my $interval = AttrVal ($hash->{NAME}, "interval", 60);
    InternalTimer(gettimeofday()+$interval, "SONYTV_poll", $hash, 1);   
    SONYTV::getPowerStatus($hash);   
}



# communication with TV ####################################################
package SONYTV;



sub getPowerStatus{
    my ($hash) = @_;
    main::Log(5,"$hash->{NAME}: staring getPowerStatus");
    my $param={
    	hash => $hash,
    	callback => \&getPowerStatus_response,
    	url => "http://$hash->{host_name}/sony/system", 
    	timeout => 2,
    	data => '{"id":20,"method":"getPowerStatus","version":"1.0","params":[]}',
    	method => "POST",
    	header => {
            'Content-Type' => 'application/json',
    	},
    };
    main::Log(5,"$hash->{NAME}: url: $param->{url}");
    main::HttpUtils_NonblockingGet($param);
    return 0;
}

sub getPowerStatus_response {
    my ($param, $err, $data) = @_; 
    my $hash = $param->{hash};	
    my $status;
    my $errormessage;

    main::Log(5,"$hash->{NAME}: got response for getPowerStatus");
    main::Log(5,"$hash->{NAME}: err: $err");
    main::Log(5,"$hash->{NAME}: data: $data");
   
    if (!$err eq "" or !defined($data) or $data eq ""){
	    if (index($err, "timed out") != -1){
	        $status = "offline";	
	    } else {
	    	$status = "ERROR";
            $errormessage = $err;           
		    main::Log(2, "Error in $hash->NAME: $err") if defined $err;
	    } 
    } else {
    	$data = ::decode_json($data);
    	$status = $data->{result}[0]{status};
    }
    
    $hash->{STATE} = $status;
    
    main::readingsBeginUpdate($hash);
    main::readingsBulkUpdate($hash,"status",$status);
    if (defined $errormessage) {
        main::readingsBulkUpdate($hash,"error_message",$errormessage);
    } else {
    	main::fhem("deletereading $hash->{NAME} error_message");
    }
    main::readingsEndUpdate($hash, 1);
    
}


1;
