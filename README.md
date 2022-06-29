# PHP docker image compiled with `sqlite3_enable_load_extension` enabled

# Introduction
This works by applying two patches.\
`sqlite_driver.c.patch`: adds a call to `sqlite3_enable_load_extension(H->db, 1);` so it is possible from SQL to load the 
                         `libspatialite` extension.\
`Dockerfile.patch`: adds instructions to apply the `sqlite_driver.c.patch` during the docker image build process.

Note that the `php-src` folder _is not used for compiling the image_, it is only there to use as a reference for creating the
necessary patch.

## Instructions
1. Open `Makefile` and adjust ENV variables to desired versions and values.
2. Run `make`.
3. Test your new image.
4. Run `make push` to make available online.

## TODO
[ ] Build new images automatically based on an upstream git trigger.

## Troubleshooting
- The patch could not be applied during docker build (sqlite_driver.c.patch)
  - Although very rare, the signature of the `sqlite_driver.c` file has changed too much for the patch to be able to apply itself.
    A new patch file needs to be generated. 
    - Look for the sqlite driver file in `php-src`. 
    - Look for a function that looks like a constructor/factory (a point that will always be hit when loading the sqlite driver)
    - Add `sqlite3_enable_load_extension(H->db, 1);`. The `1` means "enabled". The `H-db` is a reference to the db object for the 
      driver. Note that the variable name might be changed in the future so look for references to `->db`, it will most likely be 
      the correct reference.
    - Create a new patch with `./php-src$ git diff > ../sqlite_driver.c.patch` and commit and push it so others will be able to
      build new images as well.
- The patch could not be applied before docker build (Dockerfile.patch)
  - Although rare, the signature of the `Dockerfile` in the `php` (docker images) folder has changed too much for the patch to be
    able to apply itself. A new patch file needs to be generated. 
    - In the `php` folder open one of the recent version and open the `Dockerfile`.
    - Copy the patch onto the image `COPY sqlite_driver.c.patch /usr/src/php/sqlite_driver.c.patch`. Make sure to check the folder
      is the same folder where the source is extracted.
    - Add a line for the apk installation of `patch`.
    - Add a line in the `RUN` section that will apply the patch after the source was extracted. It should be somewhere after \
      `docker-php-source extract; \ ` \
      `cd /usr/src/php; \ `

      `patch -p4 ext/pdo_sqlite/sqlite_driver.c < sqlite_driver.c.patch;`.
    - Create the new patch: `./php$ git diff > ../Dockerfile.patch`
