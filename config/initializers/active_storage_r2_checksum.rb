# Prevent Active Storage from adding Content-MD5 so R2 doesn't see two checksums.

Rails.application.config.to_prepare do
  next unless defined?(ActiveStorage::Service::S3Service)

  ActiveStorage::Service::S3Service.prepend(Module.new do
    private

    # Rails 7/8 signature: upload(key, io, checksum: nil, **options)
    def upload(key, io, checksum: nil, **options)
      instrument :upload, key: key, checksum: checksum do
        put_opts = { body: io }
        put_opts[:content_type]   = options[:content_type]   if options[:content_type]
        put_opts[:content_length] = options[:content_length] if options[:content_length]

        # IMPORTANT: don't pass content_md5 / checksum at all
        object_for(key).put(**put_opts.merge(upload_options))
      end
    end
  end)
end
