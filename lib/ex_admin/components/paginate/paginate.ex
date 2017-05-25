defmodule ExAdmin.Components.Paginate do
  @moduledoc """
  An ExAdmin pagination Component.
  """

  import Phoenix.HTML.Tag
  import Phoenix.HTML.Link

  @links_container_class "pagination pagination-sm no-margin pull-right"
  @information_container_class "pagination_information"
  @page_gap_class "page gap"
  @ellipse " ..."
  @first_text "« First"
  @prev_text "‹ Prev"
  @next_text "Next ›"
  @last_text "Last »"
  @window_size 7
  @active_class "active"
  @displaying_text "Displaying"
  @show_information true

  @doc """
  Create pagination links and information line.

  ## Options

  * :links_container_class (#{@links_container_class})
  * :information_container_class (#{@information_container_class})
  * :page_gap_class (#{@page_gap_class})
  * :ellipse (#{@ellipse})
  * :first_text (#{@first_text})
  * :priv_text (#{@prev_text})
  * :next_text (#{@next_text})
  * :last_text (#{@last_text})
  * :window_size (#{@window_size})
  * :active_class (#{@active_class})
  * :displaying_text (#{@displaying_text})
  * :show_information (#{@show_information})
  """
  def paginate(link, page_number, page_size, total_pages, record_count, name, opts \\ []) do
    links_container_class = opts[:links_container_class] || @links_container_class
    information_container_class = opts[:information_container_class] || @information_container_class
    container =
      content_tag :ul, class: links_container_class do
        if total_pages > 1 do
          for item <- items(page_number, page_size, total_pages, opts) do
            build_item link, item, opts
          end
        else
          []
        end
      end

    if opts[:show_information] do
      [
        container,
        content_tag :ul, class: information_container_class do
          record_number = (page_number - 1) * page_size + 1
          display_pagination name, (page_number - 1) * page_size + 1, page_size,
                            record_count, record_number + page_size - 1, opts
        end
      ]
    else
      container
    end
    |> Phoenix.HTML.Safe.List.to_iodata
    |> Phoenix.HTML.raw
  end

  defp build_item(_, {:current, num}, opts) do
    active_class = opts[:active_class] || @active_class
    content_tag :li, class: active_class do
      link "#{num}", to: "#"
    end
  end

  defp build_item(_, {:gap, _}, opts) do
    page_gap_class = opts[:page_gap_class] || @page_gap_class
    ellipse = opts[:elipse] || @ellipse
    content_tag :li, class: page_gap_class do
      content_tag :span do
        ellipse
      end
    end
  end

  defp build_item(link, {item, num}, opts) when item in [:first, :prev, :next, :last] do
    content_tag :li do
      link "#{special_name item, opts}", to: "#{link}&page=#{num}"
    end
  end

  defp build_item(link, {_item, num}, _) do
    content_tag :li do
      link "#{num}", to: "#{link}&page=#{num}"
    end
  end


  defp display_pagination(name, _record_number, 1, record_count, _, opts) do
    pagination_information(name, record_count, opts)
  end
  defp display_pagination(name, record_number, _page_size, record_count, last_number, opts)
      when last_number < record_count do
    pagination_information(name, record_number, last_number, record_count, opts)
  end
  defp display_pagination(name, record_number, _page_size, record_count, _, opts) do
    pagination_information(name, record_number, record_count, record_count, opts)
  end

  defp pagination_information(name, record_number, record_number, record_count, opts) do
    displaying = opts[:displaying_text] || @displaying_text
    [
      displaying  <> Inflex.singularize(" #{name}") <> " ",
      content_tag(:b, do: "#{record_number}"),
      " " <> "of" <> " ",
      content_tag(:b, do: "#{record_count}"),
      " " <> ("in total")
    ]
    |> Phoenix.HTML.Safe.List.to_iodata
    |> Phoenix.HTML.raw
  end

  defp pagination_information(name, record_number, last, record_count, opts) do
    displaying = opts[:displaying_text] || @displaying_text
    [
      ("#{displaying} #{name}") <> " ",
      content_tag(:b, do: "#{record_number} - #{last}"),
      " " <> ("of") <> " ",
      content_tag(:b, do: "#{record_count}"),
      " " <> ("in total")
    ]
    |> Phoenix.HTML.Safe.List.to_iodata
    |> Phoenix.HTML.raw
  end

  defp pagination_information(name, total, opts) do
    displaying = opts[:displaying_text] || @displaying_text

    [
      displaying <> " ",
      content_tag(:b, do: ("all #{total}")),
      " #{name}"
    ]
    |> Phoenix.HTML.Safe.List.to_iodata
    |> Phoenix.HTML.raw
  end

  def special_name(:first, opts), do: opts[:first_text] || @first_text
  def special_name(:prev, opts), do: opts[:prev_text] || @prev_text
  def special_name(:next, opts), do: opts[:next_text] || @next_text
  def special_name(:last, opts), do: opts[:last_text] || @last_text

  def window_size(opts), do: opts[:window_size] || @window_size

  def items(page_number, page_size, total_pages, opts) do

    prefix_links(page_number)
    |> prefix_gap
    |> links(page_number, page_size, total_pages, opts)
    |> postfix_gap
    |> postfix_links(page_number, total_pages)
  end

  def prefix_links(1), do: []
  def prefix_links(page_number) do
    prev = if page_number > 1, do: page_number - 1, else: 1
    [first: 1, prev: prev]
  end

  def prefix_gap(acc) do
    acc
  end

  def postfix_gap(acc), do: acc

  def links(acc, page_number, _page_size, total_pages, opts) do
    half = Kernel.div window_size(opts), 2
    before = cond do
      page_number == 1 -> 0
      page_number - half < 1 -> 1
      true -> page_number - half
    end
    aftr = cond do
      before + half >= total_pages -> total_pages
      page_number + window_size(opts) >= total_pages -> total_pages
      true -> page_number + half
    end
    before_links = if before > 0 do
      for x <- before..(page_number - 1), do: {:page, x}
    else
      []
    end
    after_links = if page_number < total_pages do
      for x <- (page_number + 1)..aftr, do: {:page, x}
    else
      []
    end
    pregap = if before != 1 and page_number != 1, do: [gap: true], else: []
    postgap = if aftr != total_pages and page_number != total_pages, do: [gap: true], else: []
    acc ++ pregap ++ before_links ++ [current: page_number] ++ after_links ++ postgap
  end

  def postfix_links(acc, page_number, total_pages) do
    if page_number == total_pages do
      acc
    else
      acc ++ [next: page_number + 1, last: total_pages]
    end
  end
end
