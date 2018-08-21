# Magento 2.2+ Docker Stack
My default docker environment for Magento 2

## Highlights
- Support docker-compose file V3 - easy to scale up;
- Magento 2.2+ ready, B2B included;
- SSL Ready - self-signed certificate for now;
- NodeJS included for Grunt tasks;
- Mail system ready (MailHog)
- Easily configurable;
- Multistore ready;
- Best documented;

## How To Use

### New Projects or Clean Magento Installation (Magento Commerce Version 2.2+)

1. Download master branch and unzip it into a folder of your preference;
2. Review the config.env file and change it according to your needs;
3. Open your local hosts (/etc/hosts) file and add the same domain as in your config.env file;
4. Start your docker stack environment, from the root folder, where docker-compose.yml lies:
    * `$ docker-compose up -d`
4. Connect to PHP container;

    * `$ docker exec -ti [container-name] bash`

5. run composer create project, this command will download Magento's composer package;

    * `$ composer create-project --repository-url=https://repo.magento.com/ magento/project-enterprise-edition project`

    * If you want a specific version, you should pass the version as parameter;

        * `$ composer create-project --repository-url=https://repo.magento.com/ magento/project-enterprise-edition project 2.2.0`

6. Now you should install Magento itself;
    * Browser installation:
        * Go to the domain from step 3 using your browser;
        * Our certificate is self-signed, thus you need to add an exception in your browser for your chosen domain;
        * Follow the instructions;
    * CLI installation:
        * Connect to your PHP container:
            * `$ docker exec -ti [container-name] bash`
        * Go to Magento's root folder and run:
            * `$ php bin/magento setup:install --base-url=http://base.magento.local --use-secure=1 --base-url-secure=https://base.magento.local --backend-frontname=admin --use-secure-admin=1 --db-host=db --db-name=magento --db-user=magento --db-password=magento --admin-firstname=User --admin-lastname=Magento --admin-email=developer@magento.com.br --admin-user=admin --admin-password=demo1234 --language=pt_BR --currency=BRL --timezone=America/Sao_Paulo --cleanup-database --session-save=db --use-rewrites=1`
                * Change the parameters according to your needs.
                * The db-host parameter will always be **'db'** for both, browser or CLI installation
7. Now you can access your Magento installation through your domain.


### Existing Projects Installation (Magento Commerce Version 2.2+)

1. Download master branch and unzip it into a folder of your preference;
2. Review the config.env file and change it according to your needs;
3. Open your local hosts (/etc/hosts) file and add the same domain(s) as in your config.env file;
4. Start your docker stack environment, from the root folder, where docker-compose.yml lies:
    * `$ docker-compose up -d`
5. Connect to PHP container;
    * `$ docker exec -ti [container-name] bash`
6. Run all Magento's CLI commands that you need;
7. To import your project's database, connect with any MySQL client to the localhost's 3306 port. That port is linked from MySQL container to your localhost; 

### Extras
#### Magento Cron
Magento 2.2 has a CLI command to configure cron tasks, just connect into your PHP container and run:  

    * `$ php bin/magento cron:install`

Use --force to rewrite an existing Magento crontab.

We do recommend to set the all indexers to 'schedule' mode:
1. Connect to PHP container;

    * `$ docker exec -ti [container-name] bash`

2. Run this CLI command:
    * `$ php bin/magento indexer:set-mode schedule`

#### Using Redis
We're using just one Redis instance.
So we should set different Redis' databases for each feature.

1. Redis as default caching - DB 0 [required]
    * `$ php bin/magento setup:config:set --cache-backend=redis --cache-backend-redis-server=redis --cache-backend-redis-port=6379 --cache-backend-redis-db=0`

2. Redis Page Caching - DB 1
    * `$ php bin/magento setup:config:set --page-cache=redis --page-cache-redis-server=redis --page-cache-redis-port=6379 --page-cache-redis-db=1 --page-cache-redis-compress-data=1`

3. Redis for Session Storage - DB 2
    * `$ php bin/magento setup:config:set --session-save=redis --session-save-redis-host=redis --session-save-redis-port=6379 --session-save-redis-log-level=4 --session-save-redis-db=2`

#### Magento's Sample Data
To install sample data, fallow this steps:

1. Connect to your PHP container;
2. Set Magento to developer mode;
    * `php bin/magento deploy:mode:set developer`
3. Enable Sample Data:
    * `php bin/magento sampledata:deploy`

#### Magento's B2B module

If you want to use Magento B2B module, you can add it through composer.

1. Use composer to install B2B module:
    * `$ composer require magento/extension-b2b`
2. Finish setup:
    * `$ php bin/magento setup:upgrade`
    * `$ php bin/magento setup:di:compile`
    
3. To use shared catalog you need to set message queue up.
    * Check if the right consumers are available:
        * `$ php bin/magento queue:consumers:list`

    * You should see the following ones:
        * sharedCatalogUpdatePrice
        * sharedCatalogUpdateCategoryPermissions
    * Start each consumer separately:
        * `$ php bin/magento queue:consumers:start sharedCatalogUpdatePrice &`
        * `$ php bin/magento queue:consumers:start sharedCatalogUpdateCategoryPermissions &`
            * For now you have to start those consumers every time you start your docker stack (just after  docker-compose up -d)

4. Enable B2B features in Magento Admin at  **Stores > Configuration > General > B2B Features**;

#### Mail System
We are using Mailhog to catch e-mail sent by Magento, no matter for which address they are being sending.
We can access all e-mail catched going to the configured domain through the port 8025: Ex. base.magento.local:8025