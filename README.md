## Deploy Microsoft SQL Server Failover Cluster Instances on EC2 and FSx using Terraform

When Microsoft SQL Server databases are migrated to AWS, the first choice is Amazon RDS for SQL Server. However, there are cases where Amazon RDS is not suitable and Microsoft SQL Server needs to be deployed on Amazon EC2, and deploying SQL Server in a highly available architecture is essential. In this solution, SQL Server Failover Cluster Instances (FCI) are installed across Windows Server Failover Clustering (WSFC) nodes.

The included terraform module provisions up to two EC2 SQLServer instances with an FSx share acting as the quorum witness and storing shared data and log files. Regardless of the number of instances configured (typically 1 for development environments and 2 for production environments) the SQLServer instance nodes will always create and join an FCI cluster to ensure environmental parity. For configurations which use 2 nodes for high availability, an internal Network Load Balancer will be provisioned, which uses a health probe configured on the FCI cluster to identify which node is the primary.

The code in this repository helps you set up the following target architecture

[Target architecture diagram](images/architecture.png)

For prerequisites and instructions for using this AWS Prescriptive Guidance pattern, see [Pattern title](link to pattern on the external APG site).

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.

