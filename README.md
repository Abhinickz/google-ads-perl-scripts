
# Google-Ads-perl-scripts

Contains Google Ads Perl Script Examples:

## Requirements

* [Google Ads API Client Library for Perl](https://github.com/googleads/google-ads-perl) Setup.

####
```bash
$ perl google_ads_ip_block.pl -customer_id 1234567891 -campaign_id 111111111111 -ip_block '192.168.0.1,192.34.23.4'
Campaign criterion with resource name 'customers/1234567891/campaignCriteria/111111111111~3433566528' was modified.
Campaign criterion with resource name 'customers/1234567891/campaignCriteria/111111111111~2126178945512' was modified.

$ perl blocked_ip_addresses.pl -customer_id 1234567891
Blocked IP: '192.168.0.1/32'
Blocked IP: '192.168.23.1/32'
Blocked IP: '192.34.23.5/32'
Blocked IP: '182.168.23.1/32'
Blocked IP: '182.168.23.0/24'
Blocked IP: '192.34.23.4/32'
```