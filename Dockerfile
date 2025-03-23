FROM php:8.3-cli

# Mettre à jour les paquets et installer des dépendances
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    git unzip nano vim tree curl npm htop wget bash sudo ca-certificates lsb-release \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# PHP Extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    bcmath gd imagick intl mbstring http ctype \
    pdo_pgsql tokenizer pdo_mysql mysqli zip xml

# Installer Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Installer NVM et Node.js pour tous les utilisateurs
RUN curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> /etc/profile.d/nvm.sh && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"' >> /etc/profile.d/nvm.sh && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"' >> /etc/profile.d/nvm.sh && \
    bash -c "source /etc/profile.d/nvm.sh && nvm install 20 && nvm use 20 && npm install --global yarn"

# Rendre NVM accessible pour l'utilisateur code
USER code
RUN bash -c "source /etc/profile.d/nvm.sh && nvm use 20"

# Installer la Symfony CLI
RUN curl -sS https://get.symfony.com/cli/installer | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony

# Définir les arguments pour l'UID et le GID du développeur
ARG USER_ID=1000
ARG GROUP_ID=1000

# Créer un utilisateur "code" avec UID/GID
RUN groupadd -g $GROUP_ID code \
    && useradd -m -u $USER_ID -g code -s /bin/bash code \
    && echo "code:password" | chpasswd \
    && mkdir /home/code/workspace \
    && chown -R code:code /home/code/

# Changer d'utilisateur pour installer PNPM
USER code
RUN curl -fsSL https://get.pnpm.io/install.sh | /bin/bash -

# Ajouter "code" au sudoers avec accès sans mot de passe
USER root
RUN echo "code ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Configuration de .bashrc pour l'utilisateur "code"
RUN echo "alias ll='ls -lah'" >> /home/code/.bashrc && \
    echo "alias ss='symfony serve -d --listen-ip=0.0.0.0'" >> /home/code/.bashrc && \
    echo "alias symc='symfony console'" >> /home/code/.bashrc && \
    echo "alias slog='symfony server:log'" >> /home/code/.bashrc && \
    echo "PS1='\[\033[0;35m\]\u@\h:\[\033[1;32m\]\w\[\033[0;35m\] \$ \[\033[0m\]'" >> /home/code/.bashrc && \
    chown code:code /home/code/.bashrc  

# Exposer les ports pour le développement
EXPOSE 8000
EXPOSE 5173

# Définir le répertoire de travail
WORKDIR /home/code/
