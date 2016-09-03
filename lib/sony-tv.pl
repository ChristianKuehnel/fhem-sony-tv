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


use warnings;
use strict;

use HTTP::Request;
use LWP::UserAgent;
use JSON;
use Data::Dumper;
use experimental 'smartmatch';
 
# status values are: 
#    alive = TV is on
#    standby = TV is reachable, but off
#    offline = TV is unreachable

sub get_tv_status{

	
	my $uri="http://$host_name/sony/system";
	my $data = '{"id":20,"method":"getPowerStatus","version":"1.0","params":[]}';
	
	my $req = HTTP::Request->new( 'POST', $uri );
	$req->header( 'Content-Type' => 'application/json' );
	$req->content( $data );
	
	my $lwp = LWP::UserAgent->new;
	$lwp->timeout(2);
	my $res = $lwp->request( $req );
	if ($res->{_rc} == 500 and $res->{_headers}{"client-warning"} eq "Internal response" ) {
		return "offline";
	} elsif ($res->{_rc} != 200) {
		print "Error $res->{_rc} in HTTP request: $res->{_msg}\n";
		return "ERROR";		
	} 
	my $status = decode_json($res->{_content})->{result}[0]{status};
	return $status;
	
}

print "The TV status is: ",get_tv_status($host_name),"\n";

