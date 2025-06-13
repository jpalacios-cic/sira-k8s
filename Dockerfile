FROM redmine:6.0.1-alpine

ENV REDMINE_PLUGINS_MIGRATE="true"

# Themes
# COPY --chown=redmine:redmine files/themes/ /usr/src/redmine/public/themes/
COPY --chown=redmine:redmine files/themes/ /usr/src/redmine/app/assets/themes/

# Downloaded plugins
COPY --chown=redmine:redmine files/plugins/ plugins/

# MAKE - Lo necesita el plugin XLSX
RUN apk add g++ make

# From source plugins
USER redmine:redmine
RUN set -ex \
    # Additionals
    && git clone --depth 1 -b 4.0.0 https://github.com/alphanodes/additionals.git plugins/additionals \
    # Redmine base deface
    # && git clone -b master https://github.com/jbbarth/redmine_base_deface.git plugins/redmine_base_deface \
    #&& sed -i -E "s/gem 'deface', '.*?'/gem 'deface'/g" plugins/redmine_base_deface/PluginGemfile \
    # Redmine Better overview (require redmine_base_deface)
    # && git clone --depth 1 -b 6.0-better_overview https://github.com/maxrossello/redmine_better_overview.git plugins/redmine_better_overview \
    # Redmine custom workflows
    && git clone --depth 1 -b v3.0.0 https://github.com/anteo/redmine_custom_workflows plugins/redmine_custom_workflows \
    # Remine image clipboard paste
    && git clone --depth 1 -b master https://github.com/thorin/redmine_image_clipboard_paste.git plugins/redmine_image_clipboard_paste \
    # Remine lightbox
    && git clone --depth 1 -b main https://github.com/alphanodes/redmine_lightbox.git plugins/redmine_lightbox \ 
    # Redmine openid connect
    && git clone --depth 1 -b master https://github.com/devopskube/redmine_openid_connect.git plugins/redmine_openid_connect \ 
    # Remine subtask inherited fields
    # && git clone -b master https://github.com/edosoft/redmine-inherit-fields-plugin.git plugins/redmine_subtasks_inherited_fields \
    # Redmine XLSX format issue exporter (necesita si o si el archivo manifest)
    && git clone --depth 1 -b 0.2.1 https://github.com/two-pack/redmine_xlsx_format_issue_exporter plugins/redmine_xlsx_format_issue_exporter \
        && mkdir -p app/assets/config \
        && touch app/assets/config/manifest.js \
    # Redmine Selectbox Autocompleter
    && git clone --depth 1 -b v1.3.0 https://github.com/heriet/redmine-selectbox-autocompleter.git plugins/selectbox_autocompleter \
    # Redmine autoclose
    && git clone -b master https://github.com/theirix/redmine_autoclose.git plugins/redmine_autoclose

#RUN sed -i '${/gem\s\+["'\'']puma["'\'']/d;}' /usr/src/redmine/Gemfile