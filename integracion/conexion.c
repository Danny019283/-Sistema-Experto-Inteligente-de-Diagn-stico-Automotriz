#define _GNU_SOURCE
#include "conexion.h"

#include <errno.h>
#include <poll.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

static void msg(char *err, size_t n, const char *fmt, const char *a) {
    if (err) snprintf(err, n, fmt, a ? a : "");
}

int conexion_swipl_disponible(void) {
    const char *path = getenv("PATH");
    if (!path) return 0;
    char *copia = strdup(path), *resto = copia, *dir, ruta[4096];
    int ok = 0;
    while (copia && !ok && (dir = strsep(&resto, ":"))) {
        snprintf(ruta, sizeof ruta, "%s/swipl", *dir ? dir : ".");
        ok = access(ruta, X_OK) == 0;
    }
    free(copia);
    return ok;
}

int conexion_viva(const Conexion *c) { return c->pid > 0; }

void conexion_cerrar(Conexion *c) {
    if (c->fd_envio > 0) close(c->fd_envio);
    if (c->fd_lectura > 0) close(c->fd_lectura);
    if (c->pid > 0) {
        kill(c->pid, SIGTERM);
        waitpid(c->pid, NULL, 0);
    }
    free(c->buf);
    memset(c, 0, sizeof *c);
}

int conexion_abrir(Conexion *c, const char *script, char *err, size_t n) {
    int a[2], b[2];
    memset(c, 0, sizeof *c);
    c->siguiente_id = 1;
    signal(SIGPIPE, SIG_IGN); /* escribir a un swipl muerto da EPIPE, no mata la GUI */
    if (pipe(a) < 0 || pipe(b) < 0) { msg(err, n, "pipe: %s", strerror(errno)); return -1; }
    pid_t pid = fork();
    if (pid < 0) { msg(err, n, "fork: %s", strerror(errno)); return -1; }
    if (pid == 0) {
        dup2(a[0], 0); dup2(b[1], 1);
        close(a[0]); close(a[1]); close(b[0]); close(b[1]);
        execlp("swipl", "swipl", "-q", "-g", "main", "-t", "halt", script, (char *)NULL);
        _exit(127);
    }
    close(a[0]); close(b[1]);
    c->pid = pid; c->fd_envio = a[1]; c->fd_lectura = b[0];
    return 0;
}

/* Siguiente línea completa (malloc, sin '\n'), o NULL con err. */
static char *leer_linea(Conexion *c, char *err, size_t n) {
    for (;;) {
        char *nl = c->len ? memchr(c->buf, '\n', c->len) : NULL;
        if (nl) {
            size_t l = (size_t)(nl - c->buf);
            char *linea = strndup(c->buf, l);
            memmove(c->buf, nl + 1, c->len - l - 1);
            c->len -= l + 1;
            return linea;
        }
        struct pollfd p = { c->fd_lectura, POLLIN, 0 };
        int r = poll(&p, 1, CONEXION_TIMEOUT_MS);
        if (r == 0) { msg(err, n, "%s", "swipl no respondió (timeout)"); return NULL; }
        if (r < 0 && errno == EINTR) continue;
        if (c->len + 4096 > c->cap) {
            c->cap = (c->len + 4096) * 2;
            c->buf = realloc(c->buf, c->cap);
            if (!c->buf) { c->len = c->cap = 0; msg(err, n, "%s", "sin memoria"); return NULL; }
        }
        ssize_t got = r < 0 ? -1 : read(c->fd_lectura, c->buf + c->len, c->cap - c->len);
        if (got <= 0) { msg(err, n, "%s", "swipl terminó o no arrancó"); return NULL; }
        c->len += (size_t)got;
    }
}

cJSON *conexion_peticion(Conexion *c, const char *op, cJSON *args, char *err, size_t n) {
    cJSON *resp = NULL;
    char *txt = NULL, *linea = NULL;
    cJSON *req = cJSON_CreateObject();
    long id = c->siguiente_id++;

    if (!conexion_viva(c)) { msg(err, n, "%s", "sin conexión con swipl"); goto fin; }
    cJSON_AddNumberToObject(req, "id", (double)id);
    cJSON_AddStringToObject(req, "op", op);
    cJSON_AddItemToObject(req, "args", args ? args : cJSON_CreateObject());
    args = NULL;
    txt = cJSON_PrintUnformatted(req);
    size_t l = txt ? strlen(txt) : 0;
    if (!txt || write(c->fd_envio, txt, l) != (ssize_t)l || write(c->fd_envio, "\n", 1) != 1) {
        msg(err, n, "%s", "no se pudo escribir a swipl");
        conexion_cerrar(c);
        goto fin;
    }
    for (;;) { /* descarta respuestas de otros id */
        linea = leer_linea(c, err, n);
        if (!linea) { conexion_cerrar(c); goto fin; }
        cJSON *r = cJSON_Parse(linea);
        free(linea);
        cJSON *rid = r ? cJSON_GetObjectItem(r, "id") : NULL;
        cJSON *est = r ? cJSON_GetObjectItem(r, "estado") : NULL;
        if (!cJSON_IsObject(r) || !cJSON_IsString(est)) {
            cJSON_Delete(r);
            msg(err, n, "%s", "respuesta inválida de swipl");
            conexion_cerrar(c);
            goto fin;
        }
        if (cJSON_IsNumber(rid) && (long)rid->valuedouble == id) { resp = r; break; }
        cJSON_Delete(r);
    }
fin:
    cJSON_Delete(args);
    cJSON_Delete(req);
    free(txt);
    return resp;
}
