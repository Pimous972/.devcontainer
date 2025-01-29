FROM php:8.3-cli

# Dependencies
RUN apt-get update \
    && apt-get install -y \
        git \
        libicu-dev \
        libpq-dev \
        libzip-dev \
        unzip \
        wget \
        zip \
        curl \
        htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# PHP Extensions
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions \
    bcmath \
    gd \
    intl \
    mbstring \
    ctype \
    pdo_pgsql \
    tokenizer \
    pdo_mysql \
    mysqli \
    zip \
    xml

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Symfony CLI
RUN wget https://get.symfony.com/cli/installer -O - | bash \
    && mv /root/.symfony*/bin/symfony /usr/local/bin/symfony



# Node.js and Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#configuration de bashrc
# Ajouter des alias Bash et configurer PS1
RUN echo "alias ll='ls -lah'" >> ~/.bashrc && \
    echo "alias ll='ls -lah'" >> ~/.bashrc && \
    echo "alias ss='symfony serve -d --listen-ip=0.0.0.0'" >> ~/.bashrc && \
    echo "alias slog='symfony server:log'" >> ~/.bashrc && \
    echo "PS1='\n \[\033[0;35m\]┌──(\[\033[1;33m\]\u@\h\[\033[0;35m\])─($(hostname -I | cut -d " " -f 1))─(\[\033[1;32m\]\w\[\033[0;35m\]) \t \n \[\033[0;35m\]└> ​​\[\033[1;35m\]\$ \[\033[0m\]'" >> ~/.bashrc




# Working directory
WORKDIR /workspace