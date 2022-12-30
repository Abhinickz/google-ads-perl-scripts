#!/usr/bin/perl -w
# This example add given list of IPs to exclude for the given campaign.

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Google::Ads::GoogleAds::Client;
use Google::Ads::GoogleAds::Utils::GoogleAdsHelper;
use Google::Ads::GoogleAds::Utils::FieldMasks;
use Google::Ads::GoogleAds::V12::Resources::CampaignCriterion;
use
  Google::Ads::GoogleAds::V12::Services::CampaignCriterionService::CampaignCriterionOperation;
use Google::Ads::GoogleAds::V12::Utils::ResourceNames;

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
my $customer_id  = "INSERT_CUSTOMER_ID_HERE";
my $campaign_id  = "INSERT_CAMPAIGN_ID_HERE";
my $criterion_id = "27";                        # ip_block
my $ip_block;

sub campaign_exclude_ip_addresses {
    my ( $api_client, $customer_id, $campaign_id, $criterion_id, $ip_block ) =
      @_;

    my $resource_name =
      Google::Ads::GoogleAds::V12::Utils::ResourceNames::campaign_criterion(
        $customer_id, $campaign_id, $criterion_id, );

    my $operations;
    foreach my $ip ( split( ',', $ip_block ) ) {

        my $campaign_criterion =
          Google::Ads::GoogleAds::V12::Resources::CampaignCriterion->new(
            {
                resourceName => $resource_name,
                negative     => 'True',
                ipBlock      => {
                    ip_address => $ip,
                },

            }
          );

        my $campaign_criterion_operation =
          Google::Ads::GoogleAds::V12::Services::CampaignCriterionService::CampaignCriterionOperation
          ->new(
            {
                create => $campaign_criterion,
            },
          );
        push @{$operations}, $campaign_criterion_operation;
    }

    # Issue a mutate request to update the bid modifier of campaign criterion.
    my $campaign_criteria_response =
      $api_client->CampaignCriterionService()->mutate(
        {
            customerId => $customer_id,
            operations => $operations,
        }
      );

    foreach my $response ( @{ $campaign_criteria_response->{results} } ) {

        # Print the resource name of the updated campaign criterion.
        printf "Campaign criterion with resource name '%s' was modified.\n",
          $response->{resourceName};
    }

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
GetOptions(
    "customer_id=s"  => \$customer_id,
    "campaign_id=i"  => \$campaign_id,
    "criterion_id=i" => \$criterion_id,
    "ip_block=s"     => \$ip_block,
);

# Print the help message if the parameters are not initialized in the code nor
# in the command line.
pod2usage(2)
  if not check_params( $customer_id, $campaign_id, $criterion_id, $ip_block );

# Call the example.
campaign_exclude_ip_addresses( $api_client, $customer_id =~ s/-//gr,
    $campaign_id, $criterion_id, $ip_block );

=pod

=head1 NAME

campaign_exclude_ip_addresses

=head1 DESCRIPTION

This example add given list of IPs to exclude for the given campaign.

=head1 SYNOPSIS

campaign_exclude_ip_addresses.pl [options]

    -help                       Show the help message.
    -customer_id                The Google Ads customer ID.
    -campaign_id                The campaign ID.
    -ip_block                   comma separated IPs to block.

=cut

=pod

=head1 POST request format

    {
      "customerId" : "1234567891",
      "operations" : [
          {
            "create" : {
                "ipBlock" : {
                  "ip_address" : "192.168.23.1"
                },
                "resourceName" : "customers/1234567891/campaignCriteria/111111111111~27",
                "negative" : "True"
            }
          },
          {
            "create" : {
                "ipBlock" : {
                  "ip_address" : "182.168.23.*"
                },
                "resourceName" : "customers/1234567891/campaignCriteria/111111111111~27",
                "negative" : "True"
            }
          }
      ]
    }

=cut


=head1 Response

    {
        "results": [
            {
                "resourceName": "customers/1234567891/campaignCriteria/111111111111~298650447758"
            },
            {
                "resourceName": "customers/1234567891/campaignCriteria/111111111111~1934607981988"
            }
        ]
    }

=cut