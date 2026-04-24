{ config, pkgs, ... }: {

  # --- BANNER APÓS O LOGIN (MOTD) ---
  users.motd = ''
    +--------------------------------------------------------------------------+
    |                RESTRICTED ACCESS - SYSTEM AUDIT ACTIVE                   |
    +--------------------------------------------------------------------------+
    | [EN] Unauthorized access is prohibited and monitored.                    |
    | [PT] O acesso não autorizado é proibido e monitorado.                    |
    | [JP] 許可のないアクセスは禁止されており、監視されています。             |
    | [KR] 허가되지 않은 접근은 금지되며 모든 활동은 모니터링됩니다.           |
    | [RU] Несанкционированный доступ запрещен и контролируется.               |
    | [DE] Unbefugter Zugriff ist verboten und wird uberwacht.                 |
    +--------------------------------------------------------------------------+
    | Hostname: nixos-davi                                                     |
    | Security: Hardened Kernel / Lynis Audited 63+                            |
    +--------------------------------------------------------------------------+
  '';

  # --- MENSAGEM ANTES DO LOGIN (TTY GREETING) ---
  services.getty.greetingLine = ''\n \O (\s \m \r) - Davi's Secure Station'';
  
}
