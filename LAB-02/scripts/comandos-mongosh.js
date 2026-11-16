// LAB-02 — Trazabilidad en MongoDB Community | Comandos de referencia (mongosh)
// Estudiante: <TU NOMBRE>
// Los ejecuta automáticamente ejecutar-lab2.sh; aquí quedan documentados por actividad.

// ---- Función auxiliar (sección 6.4) ----
function bitacora() {
  return db.adminCommand({ getLog: "global" }).log.map(l => JSON.parse(l))
}

// ---- 6.3 Preparación (una sola vez, sin credenciales: excepción de localhost) ----
// use admin
// db.createUser({ user: "admin", pwd: "Admin_Practica_2026", roles: ["root"] })
// db.auth("admin", "Admin_Practica_2026")
// use comercial
// db.createUser({ user: "app_ventas", pwd: "Ventas_Practica_2026", roles: [{ role: "readWrite", db: "comercial" }] })
// db.clientes.insertMany([ ...5 clientes de la guía... ])

// ---- Actividad 1: edición y limitación ----
db.version()
db.adminCommand({ buildInfo: 1 }).modules      // [] en Community
db.serverCmdLineOpts().parsed

// ---- Actividad 2: incidente sin perfilado ----
db.getProfilingStatus()                        // was: 0
// (app) db.clientes.updateOne({ _id: 3 }, { $set: { rfc: "GAMA780912XXX" } })
db.system.profile.countDocuments()
bitacora().filter(e => JSON.stringify(e).includes("GAMA780912XXX")).length

// ---- Actividad 3: perfilador nivel 2 ----
db.setProfilingLevel(2)
db.getProfilingStatus()
// (app) find / updateOne (rfc XYZ) / deleteOne({ _id: 2 })
db.system.profile.find({ ns: "comercial.clientes" }).sort({ ts: 1 })

// ---- Actividad 4: filtro ----
db.setProfilingLevel(0)
db.system.profile.drop()
db.setProfilingLevel(1, { filter: { op: { $in: ["insert", "update", "remove"] } } })
db.getProfilingStatus()

// ---- Actividad 5: accesos en la bitácora ----
bitacora().filter(e => e.c === "ACCESS" && e.msg === "Failed to authenticate")
bitacora().filter(e => e.msg === "Successfully authenticated" && e.attr.user === "app_ventas").slice(-1)

// ---- Actividad 6: correlación por ctx ----
bitacora().filter(e => e.msg === "Profiler settings changed")
// bitacora().filter(e => e.ctx === "connNN" && e.msg === "Successfully authenticated")

// ---- Actividad 7: control compensatorio de privilegios ----
db.getSiblingDB("auditoria").instantaneas_privilegios.insertOne({
  momento: new Date(),
  tomada_por: db.runCommand({ connectionStatus: 1 }).authInfo.authenticatedUsers,
  usuarios: db.getUsers().users.map(u => ({ user: u.user, db: u.db, roles: u.roles }))
})
db.grantRolesToUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }])
db.revokeRolesFromUser("app_ventas", [{ role: "dbAdmin", db: "comercial" }])

// ---- Actividad 8: exportación ----
// EJSON.stringify(db.system.profile.find(...).toArray(), null, 2)
// db.adminCommand({ getLog: "global" }).log.join("\n")
