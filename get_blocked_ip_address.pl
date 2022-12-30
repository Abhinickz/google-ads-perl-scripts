#!/usr/bin/perl -w
#
#
# This example gets blocked IP addresses.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::SearchStreamHandler;
use
  Google::Ads::GoogleAds::V12::Services::GoogleAdsService::SearchGoogleAdsStreamRequest;

use Getopt::Long qw(:config auto_help);
use Pod::Usage;
use Cwd qw(abs_path);
use Data::Dumper;

# The following parameter(s) should be provided to run the example. You can
# either specify these by changing the INSERT_XXX_ID_HERE values below, or on
# the command line.
#
# Parameters passed on the command line will override any parameters set in
# code.
#
# Running the example with -h will print the command line usage.
my $customer_id = "INSERT_CUSTOMER_ID_HERE";

sub get_blocked_ip_address {
    my ( $api_client, $customer_id ) = @_;

# Create a search Google Ads stream request that will retrieve blocked IP addresses
    my $search_stream_request =
      Google::Ads::GoogleAds::V12::Services::GoogleAdsService::SearchGoogleAdsStreamRequest
      ->new(
        {
            customerId => $customer_id,
            query      =>
'SELECT campaign_criterion.ip_block.ip_address FROM campaign_criterion',
        }
      );

    # Get the GoogleAdsService.
    my $google_ads_service = $api_client->GoogleAdsService();

    my $search_stream_handler =
      Google::Ads::GoogleAds::Utils::SearchStreamHandler->new(
        {
            service => $google_ads_service,
            request => $search_stream_request
        }
      );

 # Issue a search request and process the stream response to print the requested
 # field values in each row.
    $search_stream_handler->process_contents(
        sub {
            my $google_ads_row = shift;

            if($google_ads_row->{campaignCriterion}->{ipBlock}->{ipAddress}) {
                printf "Blocked IP: '%s'\n", $google_ads_row->{campaignCriterion}->{ipBlock}->{ipAddress};
            }
        }
    );

    return 1;
}

# Don't run the example if the file is being included.
if ( abs_path($0) ne abs_path(__FILE__) ) {
    return 1;
}

# Get Google Ads Client, credentials will be read from ~/googleads.properties.
my $api_client = Google::Ads::GoogleAds::Client->new();

# By default examples are set to die on any server returned fault.
$api_client->set_die_on_faults(1);

# Parameters passed on the command line will override any parameters set in code.
GetOptions( "customer_id=s" => \$customer_id );

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2) if not check_params($customer_id);

# Call the example.
get_blocked_ip_address( $api_client, $customer_id =~ s/-//gr );

=pod

=head1 NAME

get_blocked_ip_address

=head1 DESCRIPTION

# This example gets blocked IP addresses.

=head1 SYNOPSIS

get_blocked_ip_address.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.

=cut

=head1 POST request format

    {
        "customerId" : "1234567891",
        "query" : "SELECT campaign_criterion.ip_block.ip_address FROM campaign_criterion"
    }

=cut

=head1 Response

    [
        {
            "results": [
                {
                    "campaignCriterion": {
                        "resourceName": "customers/1234567891/campaignCriteria/111111111111~30002"
                    }
                },
                {
                    "campaignCriterion": {
                        "resourceName": "customers/1234567891/campaignCriteria/111111111111~3433566528",
                        "ipBlock": {
                            "ipAddress": "192.168.0.1/32"
                        }
                    }
                },
            ],
            "fieldMask": "campaignCriterion.ipBlock.ipAddress",
            "requestId": "sz10_ZKIPOZ5K71U68lcIQ"
        }
    ]

=cut