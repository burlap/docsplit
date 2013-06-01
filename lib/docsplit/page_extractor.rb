module Docsplit

  # Delegates to **pdftk** in order to create bursted single pages from
  # a PDF document.
  class PageExtractor

    # Burst a list of pdfs into single pages, as `pdfname_pagenumber.pdf`.
    def extract(pdfs, opts)
      extract_options opts
      [pdfs].flatten.each do |pdf|
        pdf_name = File.basename(pdf, File.extname(pdf))
        FileUtils.mkdir_p @output unless File.exists?(@output)
        
        case @operation
          when 'burst'
            page_path = File.join(@output, "#{pdf_name}_%d.pdf")
            cmd = if DEPENDENCIES[:pdftailor] # prefer pdftailor, but keep pdftk for backwards compatability
              "pdftailor unstitch --output #{ESCAPE[page_path]} #{ESCAPE[pdf]} 2>&1"
            else
              "pdftk #{ESCAPE[pdf]} burst output #{ESCAPE[page_path]} 2>&1"
            end
            result = `#{cmd}`.chomp
            FileUtils.rm('doc_data.txt') if File.exists?('doc_data.txt')
            raise ExtractionFailed, result if $? != 0
            result
          when 'cat'
            page_path = File.join(@output, "#{pdf_name}_split.pdf")
            cmd = "pdftk #{ESCAPE[pdf]} cat #{ESCAPE[@pages]} output #{ESCAPE[page_path]} 2>&1"
            result = `#{cmd}`.chomp
            FileUtils.rm('doc_data.txt') if File.exists?('doc_data.txt')
            raise ExtractionFailed, result if $? != 0
            result
          end
      end
    end


    private

    def extract_options(options)
      @output = options[:output] || '.'
      @operation = options[:operation] || 'burst'
      @pages = options[:pages] || '1-end'
      #@dump = options[:dump] 
    end

  end

end