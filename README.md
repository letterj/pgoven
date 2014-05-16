pgoven
======

**Heat scripts for the Rackspace Public Cloud working with PostgreSQL**

## Disclaimer.
If you have any questions, comments or concerns about this please let me know. These tools are all evolving and I'm learning them and workflows so if you have suggestions for improvements or a better way to do things please let me know.


## Running the "heat" scripts.

I suggest using a python virtual environment. I'm going to use one in an example.  You can get information to install python vituralenv [http://docs.python-guide.org/en/latest/dev/virtualenvs/]. I'm using [] to denote special user supplied information in the code blocks.


### Create a virtual environment to run the scripts in.

<pre>
mkvirtualenv pglab --no-site-packages
workon pglab
</pre>

### Use pip to install various client tools

 * Using python-novaclient at Rackspace [http://www.rackspace.com/knowledge_center/article/installing-python-novaclient-on-linux-and-mac-os]
 * Using supernova [http://major.io/2012/06/05/supernova-manage-multiple-openstack-nova-environments-with-ease/]

<pre>
pip install supernova
pip install python-cinderclient
pip install python-heatclient
</pre>

**Create your .supernova file**

<pre>
[[rackspace cloud user name]]
NOVA_RAX_AUTH=1
OS_REGION_NAME=IAD
NOVACLIENT_INSECURE=1
OS_USERNAME=[get from your rackspace cloud account]
OS_TENANT_NAME=[get from your rackspace cloud account]
OS_PASSWORD=[get from your rackspace cloud account.  This is really your API-KEY]
NOVA_URL=https://identity.api.rackspacecloud.com/v2.0/
NOVA_VERSION="1.1"
NOVA_SERVICE_NAME=cloudServersOpenStack
OS_NO_CACHE=1
OS_AUTH_SYSTEM=rackspace
</pre>

supernova examples one basic and one overriding the region.  The latest version of supernova introduces the concept of groups. So reference the it's docs for more information.

<pre>
supernova <rackspace cloud user name> image-list

supernova <rackspace cloud user name> --os-region=DFW image-list
</pre>

**Create your .heatrc_[rackspace cloud region] file**

The heat stuff is a little odd.  You will need to hardcode the region.

<pre>
export OS_AUTH_URL=https://identity.api.rackspacecloud.com/v2.0/
export OS_USERNAME=[get from your Rackspace Cloud Account.]
export OS_TENANT_ID=[get from your Rackspace Cloud Account. Same as OS_TENANT_NAME used above.]
export HEAT_URL=https://[region].orchestration.api.rackspacecloud.com/v1/${OS_TENANT_ID}  
export OS_PASSWORD=[get from your Rackspace Cloud Account. Really the account password.]
</pre>

Source the ./heatrc file for the region you want to work in.
<pre>
source ~/.heatrc_[region]
</pre>

Example HEAT_URL, source .heatrc and test heat client installation

<pre>
export HEAT_URL=https://iad.orchestration.api.rackspacecloud.com/v1/${OS_TENANT_ID}

source ~/.heatrc_iad

heat stack-list
</pre>

**Create a key pair for nova to use for instance's root accounts; if you don't already have one**

Create the key pair and upload it to the Rackspace Cloud

<pre>
ssh-keygen -b 4096 -C "Rackspace Cloud  [Rackspace Cloud UserName] root key"
Generating public/private rsa key pair.
Enter file in which to save the key (/home/example/.ssh/id_rsa): /home/example/.ssh/[Rackspace Cloud Username]_root_rsa
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /home/example/.ssh/[Rackspace Cloud Username]_root_rsa.
Your public key has been saved in /home/example/.ssh/[Rackspace Cloud Username]_root_rsa.pub.

ssh-add /home/example/.ssh/[Rackspace Cloud Username]_root_rsa
</pre>

Add the key pair to the Rackspace Cloud region

<pre>
supernova [Rackspace Cloud Username] key-pair-add --pub-key=/home/example/.ssh/[Rackspace Cloud Username]_root_rsa.pub [Rackspace Cloud Username]_root_rsa
</pre>

**Pull down the repo**

<pre>
cd ~
git clone http://github.com/letterj/pgoven.git
</pre>

**Run a heat script**

Review the script to get determine the parameters both defaults and allowed

<pre>
heat stack-create pgtest94b-server --template-file ~/pgoven/database/postgresql-9.4beta.yaml -P "server_name=pgtest94b;ssh_key=[Rackspace Cloud Username]_root_rsa"
+--------------------------------------+------------------+--------------------+----------------------+
| id                                   | stack_name       | stack_status       | creation_time        |
+--------------------------------------+------------------+--------------------+----------------------+
| [UUID]                               | pgtest94b-server | CREATE_IN_PROGRESS | 2014-05-15T20:51:41Z |
+--------------------------------------+------------------+--------------------+----------------------+

heat stack-show [UUID]
+----------------------+-------------------------------------------------------------------------------------------------------------------------+
| Property             | Value                                                                                                                   |
+----------------------+-------------------------------------------------------------------------------------------------------------------------+
| capabilities         | []                                                                                                                      |
| creation_time        | 2014-05-15T20:51:41Z                                                                                                    |
| description          | PostgreSQL Template 9.4beta                                                                                             |
| disable_rollback     | True                                                                                                                    |
| id                   | [UUID]                                                                                    |
| links                | https://iad.orchestration.api.rackspacecloud.com/v1/[tenant]/stacks/pgtest94b-server/[UUID]                            |
| notification_topics  | []                                                                                                                      |
| outputs              | [                                                                                                                       |
|                      |   {                                                                                                                     |
|                      |     "output_value": "ssh root@[IP]",                                                                         |
|                      |     "description": "ssh",                                                                                               |
|                      |     "output_key": "ssh"                                                                                                 |
|                      |   }                                                                                                                     |
|                      | ]                                                                                                                       |
| parameters           | {                                                                                                                       |
|                      |   "server_name": "pgtest94b",                                                                                           |
|                      |   "OS::stack_id": "[UUID]",                                                               |
|                      |   "OS::stack_name": "pgtest94b-server",                                                                                 |
|                      |   "image": "Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)",                                                                    |
|                      |   "ssh_key": "[Rackspace Cloud Username]",                                                                                          |
|                      |   "flavor": "4 GB Performance",                                                                                         |
|                      |   "postgres_version": "9.4"                                                                                             |
|                      | }                                                                                                                       |
| stack_name           | pgtest94b-server                                                                                                        |
| stack_status         | CREATE_COMPLETE                                                                                                         |
| stack_status_reason  | Stack CREATE completed successfully                                                                                     |
| template_description | PostgreSQL Template 9.4beta                                                                                             |
| timeout_mins         | 60                                                                                                                      |
| updated_time         | None                                                                                                                    |
+----------------------+-------------------------------------------------------------------------------------------------------------------------+

ssh root@[IP]
The authenticity of host '[IP] (IP)' can't be established.
RSA key fingerprint is [FINGERPRINT].
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '[IP]' (RSA) to the list of known hosts.
Welcome to Ubuntu 14.04 LTS (GNU/Linux 3.13.0-24-generic x86_64)

 * Documentation:  https://help.ubuntu.com/

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

Last login: Thu Jan  1 00:00:10 1970
root@pgtest94b:~# su - postgres
postgres@pgtest94b:~$ psql
psql (9.4beta1)
Type "help" for help.

postgres=#

</pre>


##  HAVE FUN AND ENJOY
