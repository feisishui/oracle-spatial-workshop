==========================================================
Installing Glassfish
==========================================================

NOTE:

Glassfish needs a JDK 1.6 or better. It uses the default java command. Check your java version first by doing

  java -version


1) Extract "archive ogs-3.1.2.2.zip" into a directory called  "ogs".

01_UNCOMPRESS_ARCHIVE
...
This will create the following directory structure:

... /Spatial-Workshop
      /kits
        /glassfish
          /ogs
            /glassfish3
              /bin
              /glassfish
              ...


2) Copy the JDBC driver in the lib directory

02_INSTALL_JDBC_DRIVER

3) Start the default Glassfish domain

03_START_DOMAIN

This launches the Glassfish server and exits.

4) Create the mapadmin user

04_CREATE_MAPADMIN_USER

This uses the asadmin tool to define the new user.

You will be prompted for the password for the password of the new "mapadmin" user (entered twice)

  Enter the user password> *********
  Enter the user password again> *********
  Command create-file-user executed successfully.

By default, GlassFish's "admin" account is installed without any password. If you modified that account to use a password, then you will also be prompted for that password:

  Enter admin password for user "admin">

5) Fixup mapviewer.ear file

05_FIXUP_MAPVIEWER

This adds the glassfish-web.xml to the mapviewer.ear archive. It decompresses the archive and the web.war file, copies the glassfish-web.xml into the WEB-INF, then repacks everything into mapviewer_ogs.ear


6) Deploy MapViewer

Use GlassFish's admin console, or use the command-line interface using the following script:

06_DEPLOY_MAPVIEWER

This uses the asadmin tool to deploy the application. If necessary, you will be prompted for the password of the "admin" user.
