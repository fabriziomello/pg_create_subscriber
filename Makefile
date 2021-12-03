PGFILEDESC = "pg_create_subscriber - create logical subscriber using base backup"

SCRIPTS_built = pg_create_subscriber

EXTRA_CLEAN += pg_create_subscriber.o

PG_CONFIG ?= pg_config

PGVER := $(shell $(PG_CONFIG) --version | sed 's/[^0-9]//g' | cut -c 1-2)

PG_CPPFLAGS += -I$(libpq_srcdir) -Werror=implicit-function-declaration
SHLIB_LINK += $(libpq)

PGXS = $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

pg_create_subscriber: pg_create_subscriber.o
	$(CC) $(CFLAGS) $^ $(LDFLAGS) $(LDFLAGS_EX) $(libpq_pgport) $(LIBS) -o $@$(X)
