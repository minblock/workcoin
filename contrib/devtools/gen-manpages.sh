#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

WORKCOIND=${WORKCOIND:-$SRCDIR/workcoind}
WORKCOINCLI=${WORKCOINCLI:-$SRCDIR/workcoin-cli}
WORKCOINTX=${WORKCOINTX:-$SRCDIR/workcoin-tx}
WORKCOINQT=${WORKCOINQT:-$SRCDIR/qt/workcoin-qt}

[ ! -x $WORKCOIND ] && echo "$WORKCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
WOKVER=($($WORKCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$WORKCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $WORKCOIND $WORKCOINCLI $WORKCOINTX $WORKCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${WOKVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${WOKVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
